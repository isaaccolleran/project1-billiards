%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR Isaac Colleran
% CLASS board
% ABOUT this is the class container for the board objects
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef board %the table of the pool
    properties
        numBalls %number of balls on the table
        balls %array of ball objects
        dimensions %array containing dimensions of table
        numSunk %number of balls sunk
        centre = [0 0]
        holeR = 1.5 %tolerance for the radius of the holes on the table
    end
    
    methods
        function newBoard = board(inBalls, inDimensions)
            if nargin==2
                newBoard.numBalls = length (inBalls);
                newBoard.balls = inBalls;
                newBoard.dimensions = inDimensions;
                newBoard.numSunk = 0;
            %else will create a default table 
            else
                newBoard.numBalls = 16;
                newBoard.dimensions = [1.1 2.2];
                newBoard.numSunk = 0;
                
                %centre of board is pos = [0 0]
                d = newBoard.dimensions; 
                r = 0.053;
                ballR = 0.052;
                vel = [0 0]; %initial velocity 0
                
                %Setting the positions of each of the balls manually
                
                balls(1) = ball ([0 -1/4*d(2)], vel, ballR);
                balls(2) = ball ([0 1/4*d(2)], vel, ballR);
                refPos = balls(2).pos;
                balls(3) = ball (refPos-2*r*[sind(30) -cosd(30)], vel, ballR);
                refPos = balls(3).pos;
                balls(4) = ball (refPos-2*r*[sind(30) -cosd(30)], vel, ballR);
                refPos = balls(4).pos;
                balls(5) = ball (refPos-2*r*[sind(30) -cosd(30)], vel, ballR);
                refPos = balls(5).pos;
                balls(6) = ball (refPos-2*r*[sind(30) -cosd(30)], vel, ballR);
                refPos = balls(6).pos;
                balls(7) = ball (refPos+[2*r 0], vel, ballR);
                balls(8) = ball (refPos+[4*r 0], vel, ballR);
                balls(9) = ball (refPos+[6*r 0], vel, ballR);
                refPos = balls(3).pos;
                balls(10) = ball (refPos+[2*r 0], vel, ballR);
                refPos = balls(4).pos;
                balls(11) = ball (refPos+[4*r 0], vel, ballR);
                refPos = balls(5).pos;
                balls(12) = ball (refPos+[2*r 0], vel, ballR);
                balls(13) = ball (refPos+[4*r 0], vel, ballR);
                balls(14) = ball (refPos+[6*r 0], vel, ballR);
                refPos = balls(9).pos;
                balls(15) = ball (refPos+[2*r 0], vel, ballR);
                refPos = balls(4).pos;
                balls(16) = ball (refPos+[2*r 0], vel, ballR);
                newBoard.balls = balls;
            end
        end %constructor
    end %methods
    
    methods(Static)
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION checkCollision
% ABOUT checks if there is a collision between the imported ball and the 
%       wall. If there is, it will reflect the velocity of the axis of
%       collision by making it negative and apply a dampening coefficient
%       to reduce the velocity of the ball by an amount
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function inBall = checkCollision(inBoard, inBall, inDampening)
            xWalls = [inBoard.centre(1)-0.5*inBoard.dimensions(1); inBoard.centre(1)+0.5*inBoard.dimensions(1)];
            yWalls = [inBoard.centre(2)-0.5*inBoard.dimensions(2); inBoard.centre(2)+0.5*inBoard.dimensions(2)];
                      %min                                     %max
            ballPos = inBall.pos;
            ballRad = inBall.radius;
            
            tol = inBoard.holeR;
            dimensions = inBoard.dimensions;
            
            if (ballPos(1)-ballRad <= xWalls(1)) || (ballPos(1)+ballRad >= xWalls(2)) 
            %checking vertical walls
                inBall.vel(1) = -1*inBall.vel(1);
                %changing the x velocity to be reflected off y axis
                inBall.vel = inBall.vel * inDampening;
                
                if ballPos(2)<=tol*ballRad && ballPos(2)>=-tol*ballRad
                    %sunk in middle pocket
                    inBall.sunk = true;
                elseif dimensions(2)/2-abs(ballPos(2)) <= tol*ballRad
                    %sunk in one of the top pockets
                    inBall.sunk = true;
                end
            elseif (ballPos(2)-ballRad <= yWalls(1)) || (ballPos(2)+ballRad >= yWalls(2)) %checking y
                inBall.vel(2) = -1*inBall.vel(2);
                %changing the y velocity to be reflected off x axis
                inBall.vel = inBall.vel * inDampening;
                
                if dimensions(1)/2-abs(ballPos(1)) <= tol*ballRad
                    %sunk in one of the top pockets
                    inBall.sunk = true;
                end
            %else no wall collision
            end
            
            if inBall.sunk %was sunk during this funciton
                inBall = ball.makeSunk (inBall, inBoard.numSunk);
            end
            
        end %checkCollision
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function draw(inBoard) %no imports or exports, just need to draw table
            clf; %clears figure
            centre = inBoard.centre;
            dimensions = inBoard.dimensions;
            corner = [centre(1)-0.5*dimensions(1) centre(2)-0.5*dimensions(2)];
            
            %FOR THE FRAME
            fDimensions(2) = dimensions(2) + 0.1 * dimensions(2); 
            frameWidth = (fDimensions(2)-dimensions(2))/2;
            fDimensions(1) = dimensions (1) + 2*frameWidth;
            %these numbers are just so it looks nice - same size all around
            
            fCorner = [centre(1)-0.5*fDimensions(1) centre(2)-0.5*fDimensions(2)];
            
            %FIRST DRAWS WOODEN FRAME AROUND OUTSIDE
            rectangle ('Position', [fCorner(1) fCorner(2) fDimensions(1) fDimensions(2)],...
                'FaceColor', [0.8510 0.3294 0.1020]);
            
            %rectangle draws a rectangle starting from the bottom left corner
            rectangle ('Position',[corner(1) corner(2) dimensions(1) dimensions(2)], 'FaceColor', 'g');
            %                      corner x  centre y  x length      y length 	
            
            %DRAWING POCKETS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            pocketR = inBoard.balls(1).radius * inBoard.holeR;
            v = [0 0];
            %going to create them as balls so that I can reuse the ball
            %draw function
            p(1) = ball ([corner(1) corner(2)], v, pocketR);
            p(2) = ball ([corner(1) corner(2)+0.5*dimensions(2)], v, pocketR);
            p(3) = ball ([corner(1) corner(2)+dimensions(2)], v, pocketR);
            p(4) = ball ([corner(1)+dimensions(1) corner(2)], v, pocketR);
            p(5) = ball ([corner(1)+dimensions(1) corner(2)+0.5*dimensions(2)], v, pocketR);
            p(6) = ball ([corner(1)+dimensions(1) corner(2)+dimensions(2)], v, pocketR);
            
            for num=1:6
                ball.draw (p(num), 'k')
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

            axis ([corner(1)-0.5 centre(1)+0.5*dimensions(1)+0.5 corner(2)-0.5 centre(2)+0.5*dimensions(2)+0.5])
            axis equal
            axis manual
            %freezes the axis
            
            % DRAWING BALLS %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            ball.draw(inBoard.balls(1), 'w') %first ball is white ball
            for ii=2:inBoard.numBalls-1 %will draw black ball last
                if (mod(ii,2) == 0)
                    ball.draw(inBoard.balls(ii), 'r')
                else
                    ball.draw(inBoard.balls(ii), 'y')
                end
            end
            if inBoard.numBalls>1 %needs to be at least 2 balls to draw one as black
                ball.draw(inBoard.balls(inBoard.numBalls), 'k') %last ball is black
            end
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        end %draw function
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function newBoard = clearVel (inBoard)
            for ii=1:inBoard.numBalls
                inBoard.balls(ii).vel = [0 0]; %sets velocity to 0
            end
            newBoard = inBoard;
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION velCheck
% ABOUT takes in the current table and checks if all of the balls are still
%       If none of the balls are moving, it will return true and the
%       calling function should end the program
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function allStill = velCheck (inTable)
    balls = inTable.balls;
    count = 1;
    allStill = true;
    
    while allStill && count <= inTable.numBalls
        ballVel = balls(count).vel;
        if (norm(ballVel) > 0.01)
            %if the speed of the ball is greater than 0.01
            allStill = false;
        end
        count = count + 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                           
    end %static methods
    
end %classdef
        
                

                
        