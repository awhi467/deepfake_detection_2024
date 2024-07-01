function [PreprocessedMatrix,Fs] = Speech_To_Frames(SpeechInput,Fs)

WinLen = round(.03*Fs);      % Size of the frame 30 ms
WinShift = round(.01*Fs);    % Frame shift 10 ms

NumOfFrames = floor((length(SpeechInput) - WinLen)/WinShift)+1;
TwoDimMat = 0;
for i = 1:WinLen               % Creating Window length no. of rows
    for j = 1:NumOfFrames       % Making each column as one frame
        
        % Assigning the ith element of each frame for every jth iteration
        TwoDimMat(i,j) = SpeechInput(((j-1)*WinShift)+i);  
    end
end

PreprocessedMatrix =TwoDimMat;

end