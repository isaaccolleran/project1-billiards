%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FUNCTION calcVelocity
% ABOUT imports two balls that are colliding and the dampening coefficient
%       of collisions. From that, it calculates the new velocities of each
%       of the balls (with the dampening) and returns both ball 1 and ball
%       2 to the calling funcion as an array
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [ball_1, ball_2] = calcVelocity (ball_1, ball_2, inDampening)
    v1 = ball_1.vel;
    v2 = ball_2.vel;
    deltaV = v1 - v2; 

    deltaR = ball_1.pos - ball_2.pos; %distance vector
    dist = norm (deltaR); %distance beween, scalar
    
    newV1 = v1 - dot(deltaV, deltaR)/dist^2*deltaR;
    newV2 = v2 + dot(deltaV, deltaR)/dist^2*deltaR;


    %alternative method - works exactly the same, just a longer way to do
%     un = deltaR/dist;
%     ut = [-1*un(2) un(1)];
%     
%     v1n = dot(un, v1);
%     v1t = dot(ut, v1);
%     
%     v2n = dot(un, v2);
%     v2t = dot(ut, v2);
%     
%     v1ndash = v2n;
%     v2ndash = v1n;
%     
%     v1n = v1ndash * un;
%     v2n = v2ndash * un;
%     
%     v1t = v1t * ut;
%     v2t = v2t * ut;
%     
%     newV1 = v1n + v1t;
%     newV2 = v2n + v2t;    
    
    ball_1.vel = newV1 * inDampening;
    ball_2.vel = newV2 * inDampening;
end