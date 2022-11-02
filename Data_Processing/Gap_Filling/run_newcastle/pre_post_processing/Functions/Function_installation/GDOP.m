%
% Geometric Dilution Of Precision (GDOP) error computation
% for a configuration with one monostatic site (PEY) and a bistatic site
% whose emitter is the one of the monostatic site
% N.B.: The error is normalized wrt the precision of each radial component
%       (which comes from the Doppler spectrum resolution)
%
%	revu PFO 19/12/11 23/1/12 - adapté au cas bistatique
%   Lucio Bellomo, 12/06/2012
%
% INPUTS:
% - RADAR_infos:    n-element structure (n is the number of RADAR sites),
%                   containing the RADAR site(s) informations, with fields:
%       - x_rx,y_rx:   x/y coordinates of the receiver    [km]
%       - x_tx,y_tx:   x/y coordinates of the transmitter [km]
%       - mono_bi:     1: monostatic RADAR; 2: bistatic RADAR
%       - integr_time: 1 for a reference time (no matter the value),
%                      n for n times the reference time
% - cartesian_grid: structure, with the characteristics of the cartesian grid, with fields:
%       - x,y: x/y coordinated of the grid [km]
% - map:            (optional) for debugging only
%
% OUTPUTS:
% - cartesian_grid: structure, with additional fields wrt the input structure:
%       - bistatic_distance:  bistatic distance (round-trip)                        [km]
%       - bistatic_angle:     half of the bistatic angle (theta/2)                  [deg]
%       - bistatic direction: "radial" direction pointing toward the RADAR baseline [deg]
%       - err_GDOP_u,v:       normalized GDOP error for the u and v components
%

function cartesian_grid = GDOP(RADAR_infos, cartesian_grid, varargin)

% Compute the "radial" quantities for each RADAR
% - dist:         bistatic distance (round-trip length)                          [km]
% - ang:          direction of the "radial", oriented toward the RADAR base line [deg]
% - ang_rx:       direction RX RADAR->pixel                                      [deg]
% - ang_bistatic: half of the bistatic angle (theta/2)                           [deg]
for i_site = 1 : length(RADAR_infos)
    [dist(i_site,:,:), ang(i_site,:,:), ang_rx(i_site,:,:)] = ...
                         dist_angle(RADAR_infos(i_site).x_tx,RADAR_infos(i_site).y_tx, ...
                                    RADAR_infos(i_site).x_rx,RADAR_infos(i_site).y_rx, ...
                                    RADAR_infos(i_site).mono_bi, ...
                                    cartesian_grid.x, cartesian_grid.y);
    ang_bistatic(i_site,:,:) = ang(i_site,:,:) - ang_rx(i_site,:,:);
end

% % Debugging
% if nargin == 3
%     map = varargin{1};
% end
% for i_site = 1 : length(RADAR_infos)
%     figure; hold on;
%     trace_coast(map);
%     if map.lonlat_xy == 1
%         m_pcolor(cartesian_grid.lon,cartesian_grid.lat,squeeze(ang(i_site,:,:)));
%     else
%         pcolor(cartesian_grid.x,cartesian_grid.y,squeeze(ang(i_site,:,:)));
%     end
% %     caxis([0 150]);
%     caxis([-180 180]);
%     colorbar;
% end

% Compute some terms to be used in the GDOP formula
deg_to_rad = pi/180;
bistatic_term = 1./cos( ang_bistatic*deg_to_rad );
det_term      = 1./sin( squeeze( ang(2,:,:) - ang(1,:,:) )*deg_to_rad );

% The radial-to-vector transformation matrix
A11 =  sin(squeeze(ang(2,:,:))*deg_to_rad) .* det_term;
A12 = -sin(squeeze(ang(1,:,:))*deg_to_rad) .* det_term;
A21 = -cos(squeeze(ang(2,:,:))*deg_to_rad) .* det_term;
A22 =  cos(squeeze(ang(1,:,:))*deg_to_rad) .* det_term;

% Computation of the GDOP error
% N.B.: Since the result is normalized wrt the Doppler error,
%       the integration time and the bistatic angle are taken into account
A11 = ( A11 .* squeeze(bistatic_term(1,:,:)) ./ RADAR_infos(1).integr_time ).^2;
A12 = ( A12 .* squeeze(bistatic_term(2,:,:)) ./ RADAR_infos(2).integr_time ).^2;
A21 = ( A21 .* squeeze(bistatic_term(1,:,:)) ./ RADAR_infos(1).integr_time ).^2;
A22 = ( A22 .* squeeze(bistatic_term(2,:,:)) ./ RADAR_infos(2).integr_time ).^2;

err_u = sqrt( A11 + A12 );
err_v = sqrt( A21 + A22 );

% Build the output structure
cartesian_grid.bistatic_distance = dist;           % bistatic distance
cartesian_grid.bistatic_angle    = ang_bistatic;   % half of the bistatic angle
cartesian_grid.radial_direction  = ang;            % "radial" angle (towards the RADAR baseline)
cartesian_grid.err_GDOP_u        = err_u;          % GDOP error on u
cartesian_grid.err_GDOP_v        = err_v;          % GDOP error on v
