%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR Isaac Colleran
% CLASS updatePosition
% ABOUT takes in the board, the timestep and the frictional acceleration
%       and updates the positions of each of the balls WITH FRICTIONAL
%       ACCELERATION. This function will also update the velocities, as a
%       consequence of RK4 method.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
function inBoard = updatePositions (inBoard, h, coeffK)
    for ii=1:inBoard.numBalls
        if ~inBoard.balls(ii).sunk
%             %Velocity-Verlet method (not valid)
%             accelK = calcAccelK (inBoard.balls(ii), coeffK);
%             inBoard.balls(ii).pos = inBoard.balls(ii).pos + ...
%                 h*inBoard.balls(ii).vel + h*h/2*accelK;

            %RK4 METHOD
            curBall = inBoard.balls(ii);
            vec = [curBall.pos; curBall.vel];
            F1 = RK4(vec, coeffK);
            F2 = RK4(vec + h/2*F1, coeffK);
            F3 = RK4(vec + h/2*F2, coeffK);
            F4 = RK4(vec + h*F3, coeffK);
            RK = h/6 * (F1 + 2*F2 + 2*F3 + F4);
            
            inBoard.balls(ii).pos = inBoard.balls(ii).pos + RK(1,:);
            inBoard.balls(ii).vel = inBoard.balls(ii).vel + RK(2,:);
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION RK4
% ABOUT the function that performs the runge-kutta integration calculations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function newVec = RK4 (inVec, friction)
    accel = calcAccelK(inVec (2,:), friction);
    newVec = [inVec(2,:); accel];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION calcAccelK
% ABOUT calculates the acceleration of the ball on the table dependent
%       on the direction of velocity and the coefficient of kinetic
%       friction
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function accelK = calcAccelK (inVel, coeffK)
    if norm(inVel) == 0
        accelK = [0 0];
    else
        unitVel = inVel/norm(inVel);
        accelK = -1*coeffK*unitVel;
%         accelK = -1*coeffK*inVel;
    end
end