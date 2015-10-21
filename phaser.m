% matlab phaser
fileName = 'classicBreak.wav';
[x,fs] = audioread(fileName);
x = x(:,1);
numAllpass = 4;
depth = 1; % 0 < depth < 1 
feedback = 0.7; % 0 < feedback < 1 
lfoPhase = 0; % initial phase
lfoRate = 0.5; % Hz
fMin = 440; %Hz
fMax = 1600; %Hz
delayCoeff = 0; % a1, same for all allpasses
unitDelay = zeros(numAllpass,1); % zm1
delayMin = fMin / (fs/2);
delayMax = fMax / (fs/2);
lfoIncrement = 2*pi*(lfoRate/fs);
delayFunc = @(x) (1-x)/(1+x); % sample delay time inline function
output = zeros(length(x),1);

for idx = 1 : length(x)

    y = 0; 
    lfoPhase = lfoPhase + lfoIncrement;
    if( lfoPhase >= 2*pi )
        lfoPhase = lfoPhase - (2*pi);
    end
    
    delayCoeff = delayFunc( ...
        delayMin + (delayMax-delayMin) * ((sin(lfoPhase) + 1)/2));

    % first AP stage in series gets the input, then the output is fed back
    inSamp = x(idx) + unitDelay(1) * feedback;
    y = inSamp * -delayCoeff + unitDelay(1);
    unitDelay(1) = y * delayCoeff + inSamp;
    for jdx = 1 : numAllpass
        y1 = y;
        y = y * -delayCoeff + unitDelay(jdx);
        unitDelay(jdx) = y * delayCoeff + y1;
    end
    
    output(idx) =  x(idx) + y * depth;
end

audiowrite([fileName(1:end-4) '_phaser.wav'],output,fs);
