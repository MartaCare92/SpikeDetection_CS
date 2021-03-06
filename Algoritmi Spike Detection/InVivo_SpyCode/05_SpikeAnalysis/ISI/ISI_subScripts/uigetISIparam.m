% uigetISIparam.m
% by Valentina Pasquale - March, 2008
% modified by Alberto Averna Feb 2015 for InVivo exp
function [retArgs] = uigetISIparam()
% User inputs for ISI calculation:
% retArgs.nBinsPerDec = number of bins the histogram must have per decade
% retArgs.sf = sampling frequency (to be cancelled in future versions)
% retArgs.cancelFlag = flag for aborting
retArgs = struct('nBinsPerDec',[],'sf',[],'cancelFlag',0);
PopupPrompt  = {'Number of bins per decade', 'Sampling frequency [Hz]'};         
PopupTitle   = 'Inter Spike Interval - ISI Histogram - 16el layout)';
PopupLines   = 1;
PopupDefault = {'10', '24414'};
Ianswer = inputdlg(PopupPrompt,PopupTitle,PopupLines,PopupDefault);
if isempty(Ianswer)
    retArgs.cancelFlag = 1;
else
    retArgs.sf              =  str2double(Ianswer{2,1});    
    retArgs.nBinsPerDec     =  str2double(Ianswer{1,1});    
end