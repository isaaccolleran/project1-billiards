 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR Isaac Colleran
% CLASS main
% ABOUT this is where the program is run and all of the main functions
%       reside. THIS IS DEFAULT CUE SETUP
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function main()
clear
format compact
close all

    %CONSTANTS
    h = 0.0005; %timestep
    time = 20; %max time the program is run for
    steps = ceil(time / h);
    toPlot = 25; %how often it will plot
    tol = 0.01; %tolerance for how large a velocity must be to be considered "moving"
    friction = 'on'; %'on' for friction, 'off' for no friction
    
    if strcmp(friction, 'on')
        %STARTING CONDITIONS FOR WITH FRICTION
        collision = 0.95; %dampening factor for collisions - set to 1 for off
                       %change to number less than 1 to turn it on
        kinetic = 0.85; %coefficient for kinetic friction - set to 0 for off
        static = 0.2;
    elseif strcmp(friction, 'off')
        %STARTING COLLISIONS FOR NO FRICTION
        collision = 1;
        kinetic = 0;
        static = 0;
    else %not valid
        steps = 1; %won't initialise the loop
        disp ('Invalid specifier of friction')
    end

    %CONSTRUCTING FIGURES
    f1 = figure ('Name', 'Billiards Simulation', 'NumberTitle', 'Off', 'Visible', 'off');
    f2 = figure ('Name', 'Graphs of Conservation Laws', 'NumberTitle', 'Off', 'Visible', 'off');
    
    r = 0.052;
    
    %DEFAULT CUE STARTUP
    table = board ();
    numBalls = table.numBalls;
    figure(f1)
    board.draw (table);
    title (sprintf ('time: 0, number of balls sunk: %d', table.numSunk))
    drawnow
    table.balls(1).vel = getStartVel();
    
    
    %SETTING UP ARRAYS
    time = zeros(1, steps);
    pX = zeros (1, steps);
    pY = zeros (1, steps);
    pT = zeros (1, steps); %total momentum
    KE = zeros (1, steps);
    p0 = calcMomentum (table);
    p0X(1:steps) = p0(1);
    p0Y(1:steps) = p0(2);
    
    ii=1;
    while (ii < steps && ~board.velCheck(table))
                         %table still has balls that are moving
        
        %CONSERVATION LAW CALCULATIONS %%%%%%%
        time (ii) = ii*h;
        p = calcMomentum (table);
        pX(ii) = p(1);
        pY(ii) = p(2);
        pT (ii) = norm ([pX(ii) pY(ii)]);
        KE (ii) = calcKE (table);
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % PLOTTING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if (mod(ii,toPlot) == 0)
            %will draw every *second number* of frames
            figure (f1);
            board.draw (table);
            title (sprintf ('time: %.2f, number of balls sunk: %d', h*ii, table.numSunk))
            drawnow
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        nextTable = updatePositions (table, h, kinetic);
        table = board.clearVel (table);
        
        for jj=1:numBalls
            ball_1 = nextTable.balls(jj);
            
            if ~ball_1.sunk
                ball_1 = board.checkCollision (nextTable, ball_1, collision);
                %will modify the velocity and angle inside function
                if ball_1.sunk %if just got sunk
                    table.numSunk = table.numSunk + 1;
                    table.balls(jj) = ball_1;
                    %if sunk, will update the whole ball on table
                end
            end

            
            for kk=jj+1:numBalls
                ball_2 = nextTable.balls(kk);
                
                if ~ball_1.sunk && ~ball_2.sunk && ball.checkCollision (ball_1, ball_2)
                    spd1 = norm(ball_1.vel);
                    spd2 = norm(ball_2.vel);
                    if (spd1+spd2 < static) && (spd1 < tol || spd2 < tol)
                    %if not enough energy to get second ball moving
                        ball_1.vel = [0 0];
                        ball_2.vel = [0 0];
                    else
                        [ball_1, ball_2] = calcVelocity (ball_1, ball_2, collision) ; 
                    end
                end
                nextTable.balls(kk).vel = ball_2.vel; 
                %updates ball velocity on table
            end
            

            if ~ball_1.sunk
%                 %NEW VELOCITY CALCULATIONS
%                 accelK = calcAccelK (ball_1, kinetic);
%                 ball_1.vel = ball_1.vel + h*accelK; %adds friction to the velocity
                table.balls(jj).vel = ball_1.vel; 
                %updates ball velocity on table
            end

        end
        ii = ii + 1;
        table = updatePositions (table, h, kinetic);
    end %big while loop
    
    %final kinetic energy and momentum plot
    figure (f2);
    subplot (2,1,1)
    plot (time (1:ii-1), KE (1:ii-1))
    title ('Kinetic Energy of the System')
    xlabel ('time (secs)')
    ylabel ('kinetic energy (J)')

    subplot (2,1,2)
    plot (time (1:ii-1), pX (1:ii-1), time (1:ii-1), pY (1:ii-1), time (1:ii-1),...
        p0X (1:ii-1), 'o', time (1:ii-1), p0Y (1:ii-1), 'o')

    legend ('X', 'Y', 'InitialX','InitialY')
    title ('Momentum of the System')
    xlabel ('time (secs)')
    ylabel ('momentum (kgm/s')
    
    %OUTPUT TO COMMAND WINDOW
    fprintf('MOMENTUM SUMMARY:\n X initial: %.2f\n X average: %.2f\n\n ',...
        p0X(1), mean(pX(1:ii-1)))
    fprintf('Y initial: %.2f\n Y average: %.2f\n', p0Y(1), mean(pY(1:ii-1)))
    

    
end %main

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION calcMomentum
% ABOUT imports the table and from that calculates the total momentum of
%       all of the balls on the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function p = calcMomentum (inTable)
    p = 0;
    for ii=1:inTable.numBalls
        ball = inTable.balls(ii);
        p = p + ball.mass*ball.vel;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION calcKE
% ABOUT imports the table and from that calculates the total kinetic energy 
%       of all of the balls on the table
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function KE = calcKE (inTable)
    KE = 0;
    for ii=1:inTable.numBalls
        ball = inTable.balls(ii);
        speed = norm (ball.vel);
        
        KE = KE + 0.5*ball.mass*speed*speed;
    end
end


function vel = getStartVel ()
    loop = true;
    while loop
        vel = input('input an initial velocity of white ball as 2-D vector ([x y]):\n');
        [x, y] = size(vel);

        if ~(x==1 && y==2)
            disp ('error, invalid input vector')
        else
            loop = false;
        end
    end
end
        
    
        
        



