%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR Isaac Colleran
% CLASS ball
% ABOUT this is the class container for the ball objects. An array of balls
%       is kept inside the board class object
% DATE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

classdef ball
    properties
        pos %centre of mass
        vel
        theta %direction of movement
        radius
        sunk
        mass=0.155 %mass of a pool ball
    end
    
    methods
        function newBall = ball(inPos, inVel, inRadius)
            if (nargin == 3)
                newBall.pos = inPos;
                newBall.vel = inVel; 
                newBall.theta = ball.calcAngle (newBall);
                %finds the direction of movement
                newBall.radius = inRadius;
                newBall.sunk = false;
            %else failed
            end
        end
    end %methods
    
    methods (Static)
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION checkCollision
% ABOUT checks for a collision between the two imported balls. If there is
%       a collision, this function will return 'true' to the calling
%       function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function collision = checkCollision(ball_1, ball_2)
            collision = false;
            
            pos1 = ball_1.pos;
            pos2 = ball_2.pos;
            
            r1 = ball_1.radius;
            r2 = ball_2.radius;

            if (norm(abs(pos1(1)-pos2(1))) <= (r1+r2))
                %within x values
                if (norm(abs(pos1(2)-pos2(2))) <= (r1+r2))
                    %within y values

                    dist = sqrt( (ball_2.pos(1)-ball_1.pos(1))^2 + (ball_2.pos(2)-ball_1.pos(2))^2 );
                    %distance between the two centre of balls

                    if dist <= (ball_1.radius + ball_2.radius)
                        collision = true;
                    %else not colliding
                    end 
                %else not within y values
                end
            %else not within x values
            end
        end %checkCollision
            
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION draw
% ABOUT draws the ball using the imported colour and the rectangle function
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        function draw (inBall, colour)
            pos = inBall.pos - inBall.radius;
            r = inBall.radius;
            rectangle ('Position', [pos(1) pos(2) 2*r 2*r],...
               'Curvature', [1 1], 'FaceColor', colour);


%             viscircles (pos, r, 'Color', colour, 'LineWidth', 1);
            %this essentially 'colours in' the balls by making the thickness 
            %of the line bigger
            
        end %draw function
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION calcAngle
% ABOUT calculates the direction of the velocity vector to be updated in
%       class field
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function theta = calcAngle (inBall)
            if (norm(inBall.vel) == 0 )
                %if magnitude of velocity is 0
                theta = 0;
            else
                theta = atand(inBall.vel(2)/inBall.vel(1));
            end
            
            if (inBall.vel(1) < 0 && inBall.vel(2) < 0)
                theta = 180 + theta;
            elseif (inBall.vel(1) > 0 && inBall.vel(2) < 0)
                theta = 360 - (180 - theta);
                %same as above
            end
        end
        
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION makeSunk
% ABOUT changes the imported balls position to be somewhere in the top
%       right corner. How far into the top right corner will depend on how 
%       many other balls have been sunk. This is just a visual cue to show
%       the user how many and what coloured balls have been sunk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        function inBall = makeSunk (inBall, numSunk)
            graphAxis = axis;
            graphAxis = graphAxis - inBall.radius;
            
            inBall.vel = [0 0];
            inBall.pos = [graphAxis(2)-2*inBall.radius*numSunk graphAxis(4)];
        end
            
    end %static methods
end %classdef
                    
            
    
    