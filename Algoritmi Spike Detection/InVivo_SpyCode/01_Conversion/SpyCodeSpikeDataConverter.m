% SpyCode StimData Converter
% Alberto Averna Feb 2015
clear all

phase_st=0;
fs=[]; %Sampling Frequency [Hz]
trigg=[]; %Trigger Channel
acq_time=[]; %Length of entire experiment [s]
artifact=[];
spikes=[];
Tollerance=[];% Length of first noisy part of the recording


StartFolder=selectfolder('Select the Exp Folder Contains SpikeData');

if strcmp(num2str(StartFolder),'0')
    errordlg('Wrong selection - End of Session', 'Error');
    return
else
    cd (StartFolder);
    StartFolder=pwd; % Folder containing the RawData per Channel
end

PopupPrompt  = {'Sampling frequency [samples/sec]','Number of Basal Sessions','Number of Stim Sessions','Tollerance [s]'};
PopupTitle   = 'SpyCode comp Conversion';
PopupLines   = 1;
PopupDefault = {'24414','4','3','0'};
Ianswer = inputdlg(PopupPrompt,PopupTitle,PopupLines,PopupDefault);

if isempty(Ianswer)
    cancelFlag = 1;
else
    fs  = str2num(Ianswer{1,1});
    nbasal_sessions=str2num(Ianswer{2,1});
    stim_sessions=str2num(Ianswer{3,1});
    Tollerance=str2num(Ianswer{4,1});
end

h = waitbar(0,'Please wait...');
steps = (nbasal_sessions+stim_sessions); %for the waitbar progress

cd(StartFolder)
WaveChannels=dir;

numphases = length(dir);

first=3;
[nome_exp] = find_expnum(lower(StartFolder), 'WaveStimData');

name_folder=[nome_exp '_PeakDetectionMat_TDT'];

mkdir(name_folder)

for i =first:numphases
   
    waitbar( (i-2) / steps)
    if strfind(WaveChannels(i).name,'Basal')~=0 %for each spontaneous phase
        filenamesp=WaveChannels(i).name;
        
        load(filenamesp,'BlockData','CurrData','SpikeData','StimCh','TimeRange','TrigCh');
        nameExp=BlockData.blockname;
        phase=filenamesp(end-4:end-4);
        nchannel=filenamesp(end-12:end-12);
        
        phs=str2num(phase)+str2num(phase)-1;
        
        cd(name_folder)
        
        name_Basal_subfolder=['ptrain_' nameExp '_0' num2str(phs) '_nbasal_0001'];
        pkdir= dir;
        numpkdir= length(dir);
        if isempty(strmatch(name_Basal_subfolder, strvcat(pkdir(1:numpkdir).name),'exact'))
            mkdir(name_Basal_subfolder)% Make a new directory only if it doesn't exist
            Bsubfolder=pwd;
            name_Bsubfolder_path=[Bsubfolder '/' name_Basal_subfolder];
        end
        
        for j=1:length(SpikeData)
            
            starts=((TimeRange(1))*fs);
            ends=((TimeRange(2))*fs);
            SpikeData{j}=SpikeData{j}-(starts/fs);
            SpkSample=round(SpikeData{j}.*fs);
            time=zeros(max(SpkSample),1);
            time(SpkSample)=1;
            if Tollerance~=0&&phs==1
                time(1:(ceil(Tollerance*fs)))=0;%Check for Artifact Inside Tollerance
            end
            
            peak_train=time;
            cd(name_Bsubfolder_path)
            if j<10
                save(['ptrain_' nameExp '_0' num2str(phs) '_nbasal_0001' '_0' num2str(j)],'peak_train','artifact','spikes');
            else
                save(['ptrain_' nameExp '_0' num2str(phs) '_nbasal_0001' '_' num2str(j)],'peak_train','artifact','spikes');
            end
            clear peak_train time
            
            
        end
        
        clear 'BlockData' 'CurrData' 'SpikeData' 'StimCh' 'TimeRange' 'TrigCh'
        cd(StartFolder)
        
    elseif strfind(WaveChannels(i).name,'Stim')~=0 %for each Stim phase
        filenamest=WaveChannels(i).name;
        
        load(filenamest,'BlockData','CurrData','SpikeData','StimCh','TimeRange','TrigCh');
        nameExp=BlockData.blockname;
        phase=filenamest(end-4:end-4);
        phs=str2num(phase)*2;
        nchannel=filenamest(end-12:end-12);
        
        StimDataSamples=CurrData(:,1)*fs; %Stim Time in Samples
        
        if exist('TrigCh')
            trigg=TrigCh(1);
            for x=1:length(TrigCh) %Control-->The Trigger Channel has to be the same for the entire length of the experiment
                if TrigCh(x)~=trigg
                    disp('Trigger Channel has been changed')
                    break
                end
                
            end
        else
            trigg=StimCh(1);
            for x=1:length(StimCh) %Control-->The Trigger Channel has to be the same for the entire length of the experiment
                if StimCh(x)~=trigg
                    disp('Trigger Channel has been changed')
                    break
                end
                
            end
        end
        
        cd(name_folder)
        
        name_Stim_subfolder=['ptrain_' nameExp '_0' num2str(phs) '_Stim' num2str(phase) '_' num2str(trigg)];
        
        pkdir= dir;
        numpkdir= length(dir);
        if isempty(strmatch(name_Stim_subfolder, strvcat(pkdir(1:numpkdir).name),'exact'))
            mkdir(name_Stim_subfolder)% Make a new directory only if it doesn't exist
            Ssubfolder=pwd;
            name_Ssubfolder_path=[Ssubfolder '/' name_Stim_subfolder];
        end
        
        
        for j=1:length(SpikeData)
            
            starts=((TimeRange(1))*fs);
            ends=((TimeRange(2))*fs);
            SpikeData{j}=SpikeData{j}-(starts/fs);
            SpkSample=round(SpikeData{j}.*fs);
            time=zeros(max(SpkSample),1);
            time(SpkSample)=1;
            
            
            peak_train=time;
            
            
            artifact=StimDataSamples(find(StimDataSamples>=(starts)&StimDataSamples<=(ends)));
            artifact=(artifact-(starts)-1); %shift artifact vector to 0
            
            cd(name_Ssubfolder_path)
            if j<10
                save(['ptrain_' nameExp '_0' num2str(phs) '_Stim' num2str(phase) '_' num2str(trigg) '_0' num2str(j)],'peak_train','artifact','spikes');
            else
                save(['ptrain_' nameExp '_0' num2str(phs) '_Stim' num2str(phase) '_' num2str(trigg) '_' num2str(j)],'peak_train','artifact','spikes');
            end
            clear peak_train time
            
        end
        
        clear 'BlockData' 'CurrData' 'SpikeData' 'StimCh' 'TimeRange' 'TrigCh'
        cd(StartFolder)
    end
end
warndlg('Successfully accomplished!','Conversion')
close(h)
