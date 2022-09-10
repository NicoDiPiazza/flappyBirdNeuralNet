%% flappyBird.m

% a flappy bird program, played by a Neuro evolutionary augmenting
% topology (NEAT)

%made by Domenico Di Piazza
% 9/7/22


clear;
clf;
clc

%% Parameters

global jump;

dt = 0.005;

%axis vars
axisX = 150;
axisY = axisX/2;

playAgain = true;

%tells the program whether you want to play, or have the bots play
isHuman = false;

% bot vars
goodBots = [];
N_bots = 30;
bots = [];
%fraction of bots kept
botsKeep = ceil((1/10) * N_bots);

botsDead = 0;
deadArray = zeros(1, N_bots);
mutate = 0.1;
N_gens = 1;

%array of bots initialization
for i = 1:N_bots
    bots = [bots, [(rand() * 2) - 1, (rand() * 2) - 1, (rand() * 2) - 1]];


end


while playAgain
    %bird vars
    birdY = axisY/2;
    birdX = axisY/7;

    botHeights = [];
    for i = 1:N_bots
        botHeights = [botHeights, axisY/7];
    end

    heightMod = 0;
    fallRate = 3;
    jumpRate = 5;

    %pipe vars
    pipeWidth = axisX/6;
    pipeHeight = newPipe(axisY);

    pipeRate = axisX / 20;
    pipeX = axisX;

    %game vars
    score = 0;
    keepPlaying = true;

    %% Game PLaying


    while keepPlaying
        %gameplay calculations

        %deciding which of the robots jump

        whoJumps = [];
        for i = 1:N_bots

            whoJumps = [whoJumps, botCalc(botHeights(i), pipeHeight, pipeX, weightFind(i, bots, 1), weightFind(i, bots, 2), weightFind(i, bots, 3))];


        end



        if isHuman
            key = set(figure(1),'KeyPressFcn', @myfun);
            if jump
                heightMod = jumpRate;
            elseif heightMod > -jumpRate
                heightMod = heightMod - fallRate;
            end

            birdY = birdY + heightMod;
        else
            for i = 1:N_bots
                heightMod = 0;
                if whoJumps(i)
                    heightMod = jumpRate;
                elseif heightMod > -jumpRate
                    heightMod = heightMod - fallRate;
                end

                botHeights(i) = botHeights(i) + heightMod;
            end

        end

        pipeX = pipeX - pipeRate;

        if pipeX < -pipeWidth
            pipeX = axisX;
            pipeHeight = newPipe(axisY);
            score = score + 1;
            if score/10 < axisX / 4
                pipeRate = (axisX / 20) + floor(score/5);
            else
                pipeRate = (axisX / 20) + axis/4;
            end

        end

        %keeping the bird between the ground and twice the height

        if isHuman
            keepPlaying = birdY > 0 && birdY < axisY * 2;

            if birdX >= pipeX && birdX <= pipeX + pipeWidth
                keepPlaying = (birdY >= pipeHeight && birdY <= pipeHeight + axisY/3);

            end
        else
            for i = 1:N_bots
                if birdX >= pipeX && birdX <= pipeX + pipeWidth && deadArray(i) == 0
                    if botHeights(i) < pipeHeight || botHeights(i) > pipeHeight + axisY/3
                        botsDead = botsDead + 1;
                        deadArray(i) = 1;

                    end
                end
                % storing successful bots
                if botsDead == N_bots - botsKeep
                    goodBots = -1 * (deadArray - 1);

                end
            end
            %next generation logic
            if botsDead >= N_bots
                %telling it to start the game
                keepPlaying = false;
                %generating the new array of bot weights
                ourChamps = [];
                newBots = [];
                for i = 1:N_bots
                    if goodBots(i) == 1
                        ourChamps = [ourChamps, i];
                    end
                end
                for i = 1:length(ourChamps)
                    place = (ourChamps(i) * 3) - 2;
                    newBots = [newBots, bots(place), bots(place + 1), bots(place + 2)];
                end
                % making the mutated ones
                for i = 1:N_bots - length(ourChamps)
                    gene = rand() * 3;
                    if gene<1

                        newBots = [newBots, newBots(1) + ((rand() - 0.5) * mutate), newBots(2), newBots(3)];
                    elseif gene< 2
                        newBots = [newBots, newBots(1), newBots(2) + ((rand() - 0.5) * mutate), newBots(3)];
                    else
                        newBots = [newBots, newBots(1), newBots(2), newBots(3) + ((rand() - 0.5) * mutate)];
                    end
                end

                bots = newBots;
                N_gens = N_gens + 1;
                %reseting the counters
                botsDead = 0;
                deadArray = zeros(1, N_bots);
            end
        end






        %game drawing


        %bottom pipe
        plot([pipeX, pipeX + pipeWidth], [pipeHeight, pipeHeight], 'g');
        hold on
        plot([pipeX, pipeX ], [pipeHeight, 0], 'g');
        plot([pipeX + pipeWidth, pipeX + pipeWidth], [pipeHeight, 0], 'g');
        %top pipe
        plot([pipeX,pipeX+pipeWidth],[pipeHeight+(axisY/3),pipeHeight+(axisY/3)], 'g');
        plot([pipeX, pipeX ], [pipeHeight+ (axisY / 3), axisY], 'g');
        plot([pipeX + pipeWidth, pipeX + pipeWidth], [pipeHeight+(axisY/3), axisY], 'g');
        %drawing the birds
        if isHuman
            plot(birdX, birdY, 'bo');
        else
            for i = 1:N_bots
                if deadArray(i) == 0

                    plot(birdX, botHeights(i), 'bo');
                end
            end
        end

        hold off

        axis equal
        axis([0, axisX, 0, axisY]);
        drawnow

        clc;
        disp(['score: ', num2str(score)]);
        disp(whoJumps);
        disp(goodBots);
        disp([bots(1), bots(2), bots(3)])
        disp(['Gen # ', num2str(N_gens)])
        disp(['pipe speed: ', num2str(pipeRate)]);
        pause(dt);


    end
    if isHuman

        answer = input('Do you want to play again? (s/d) ', 's');

        playAgain = false;
        if strcmp(answer, 's')
            playAgain = true;
        end
    else
        playAgain = true;


    end

end
%% functions

function myfun(~, event)
global jump;
if strcmp(event.Key, 's') == 1
    jump = true;

else
    jump = false;
end


end


function new = newPipe(max)

new = max * ((rand() * 0.5) + 0.25);
end

function botJump = botCalc(BY, PY, Pd, Wone, Wtwo, Wthree)

% input * weight calculation
factorOne = BY * Wone;
factorTwo = PY * Wtwo;
factorThree = Pd * Wthree;

%combining them all

outputFactor = factorOne + factorTwo + factorThree;
%making it boolean
if outputFactor > 0
    botJump = true;
else
    botJump = false;
end

end

function weight = weightFind(where, array, steps)

weight = array(((where-1) * 3) + steps);


end
