function [estimate,ksi,beta,est_var] = general_kriging(s,b,y,options)
% GENERAL_KRIGING computes kriging estimate for generalized case of
% uncertain mean, using the function extimate form and a user-defined
% set of standard or fft-based methods.
%
% [ESTIMATE,KSI,BETA,EST_VAR] = GENERAL_KRIGING(S,B,Y,OPTIONS)
% returns the kriging estimate for the problem specified by the input
% parameters S, B, Y, and OPTIONS. ESTIMATE is kriging result,
% KSI and BETA are the kriging weights and EST_VAR is the
% corresponding estimation variance.
%
% Input parameters are structures for:
% S:           unknowns
% B:           base functinos
% Y:           measurements
% OPTIONS:     general options describing the problem setup and user's
%              choice of method
% 
% In the current code, quality of input parameters is not yet checked
% upon startup and may result in run-time errors later on. Please read
% the following help lines carefully and test small problems before
% gaining confidence in how to handle this code. The authors give no
% warranty for the correctness of the results.
%
% Definition of prior covariance: Subfields of structure S:
% .model       geostatistical model type:
%               gaussian, exponential, spherical (to be extended)
% .variance    geostatistical model parameter for field variance:
%               positive scalar
% .lambda      geostatistical model parameter for correlation length:
%               (may be anisotropic, rotated anisotropy not implemented)
%               positive vector of length d (d is dimensionality)
% .nugget      geostatistical model parameter for nugget effect:
%               positive scalar (adds to variance)
% .micro       microscale smoothing parameter (see book by Kitanidis):
%               positive scalar, relative to .lambda
%               (applied before adding nugget)
% 
% Definition of the grid of unknowns: Subfields of structure S:
% .n_pts       number of unknowns in each direction:
%               positive integer vector of length d
% .d_pts       grid spacing in each direction:
%               positive integer vector of length d
% 
% Definition of mean: Subfields of structure B:
% .model       model type for the stochastic mean of the unknowns:
%               uncertain, known, zero or unknown (string)
% .n           model complexity (number of base functions):
%               positive scalar
% .beta_pri    prior mean coefficients for trend functions:
%               vector of length as specified in b.n
% .Qbb         uncertainty of prior mean
%               (covariance matrix for trend coefficients):
%               positive-definite square matrix sized b.n times b.n
% .function    base functions (vector of ones for constant mean):
%               matrix sized prod(n_pts) times b.n
% 
% Definition of measurement locations: Subfields of structure Y:
% .gridtype    type of measurement grid:
%               regular or irregular (string)
% .indices     location of measurements in grid of unknowns:
%               vector with length equal to number of measurements
%               (single index notation)
%               (required for irregular grids only)
% .d_ratio     resampling ratio:
%               positive integer vector of length d
%               (required for definition of regular grids only)
% .x_first     location of first measurement in grid of unknowns:
%               positive integer vector of length d
%               (multiple subscript notation)
%               (required for regular grids only)
% .n_pts       size of subsampled field in numbers of measurements
%               (because regular grid of measurements may be smaller than domain):
%               positive integer vector of length d
%               (required for regular grids only)
% 
% data set of measurements: Subfields of structure Y:
% .error       measurement error (scalar) expressed as variance:
%               positive scalar
% .values      measurement values:
%               vector with length equal to number of measurements
% 
% kriging method options: Subfields of structure OPTIONS:
% .superpos    superposition method:
%               fft or standard (string)
% .solver      solver method:
%               fft (fft-reg, fft-irreg) or standard (string)
% .estvar      estimation variance method:
%               full, one-point, speedy or none (string) ("hybrid" may be
%               added later)
% .maxprime    embedding optimization parameter:
%               2,3,5,7,... (required for both standard and fft-methods!)
% .plot        plotting flag:
%               true or false (boolean)
% 
% specific options for fft-based solvers: Subfields of structure OPTIONS:
% (required for fft-based solvers only)
% .tol         solver relative residual:
%               usually about 1e-10
% .maxit       solver maximum iteration number:
%               usually number of measurements or less
% .cond        solver regularization parameter:
%               usually 1e6, best performance in most cases according to experience
% .verbose     solver verbosity:
%               0, 1 or 2
% .kalstr      solver filter strength:
%               zero or some percent of variance
%               (approximate solution of kriging equations for no-zero value)
% .flag_Strang solver method flag:
%               true or false (boolean)
%               (true may perform better for highly correlated fields)
%
% copyright 2007 by Wolfgang Nowak.
% Affiliation:
%   Institute of Hydraulic Engineering (IWS)
%   Chair for Hydraulics and Modelling of Hydrosystems (LH2)
%   University of Stuttgart, Germany
% Email:
%   wolfgang.nowak@iws.uni-stuttgart.de
%
% Detailed information on the method used here:
% J. Fritz, W. Nowak and I. Neuweiler: FFT-based Algorithms for Kriging",
% submitted to Mathematical Geology (2007)
% 
% version 1.5,  01 august 2007 / WN

% general notation hints:
% s    unknowns
% y    observations
% b    base functions
% gs   grid for unknowns
% n    for number
% x1   spatial coordinate
% x2   spatial coordinate
% x3   spatial coordinate
% _len length
% d    grid spacing
% h    effective spacing
% _e   embedded
% _pts for points
% _    for vectors specifying values for each direction
%      vectors with same name but without _
%      are usually the product of the _ vector

%--------------------------------------------
% Checking input
%--------------------------------------------

% ensure consistency of grid types and solver methods...
if isequal(y.gridtype,'regular')   && isequal(options.solver,'fft');
  options.solver = 'fft-reg';
end
if isequal(y.gridtype,'irregular') && isequal(options.solver,'fft');
  options.solver = 'fft-irreg';
end
if isequal(y.gridtype,'irregular') && isequal(options.estvar,'speedy');
  warning('GENERAL_KRIGING:input','.options: ESTVAR option SPEEDY not allowed for Y.GRIDTYPE option IRREGULAR. Setting ESTVAR to NONE.')
  disp('Try again with ESTVAR options NONE, FULL or ONE-POINT.')
  options.estvar='none';
end
if isequal(options.estvar,'speedy') && isequal(options.superpos,'standard')
  warning('GENERAL_KRIGING:input','.options: ESTVAR options SPEEDY is useless without SUPERPOS option FFT. Setting ESTVAR to NONE.')
  disp('Try again with ESTVAR options NONE, FULL, HYBRID or ONE-POINT.')
  options.estvar='none';
end

%--------------------------------------------
% Computing auxiliary quantities
%--------------------------------------------

% generate regular grid data and coordinates for unknowns
s.domain_len = s.n_pts.*s.d_pts;                   % domain length in each direction
s.npts       = prod(s.n_pts);                      % number of unknowns
s.nd         = numel(s.n_pts);                     % dimensionality of problem
[gs.x_pts gs.x_vec]...
             = generate_grid(s.n_pts,s.d_pts,s.nd);

% % include 1D case as simplified 2D case
% if numel(s.n_pts)==1
%   s.n_pts = [s.n_pts 1];
%   s.d_pts = [s.d_pts 1];
% end
% if isfield(y,'n_pts') && numel(y.n_pts)==1
%   y.n_pts = [y.n_pts 1];
% end

% generate regular embedded covariance function (required also for non-spectral methods!)
se           = find_embedding(s,options);
Qse1         = generate_covariance_embedded_first_row(s,se);
% compute fftn(Qse1) once for all...
if isequal(options.superpos,'fft')
  fftnQse1   = fftn(Qse1);
  fftnQse1   = real(fftnQse1);
else
  fftnQse1   = [];
end

% complete measurement information
y.npts       = numel(y.values);
if ~isfield(y,'indices') && isequal(y.gridtype,'regular');
  y.nd         = s.nd;
  y.d_pts      = s.d_pts.*y.d_ratio;
  y.domain_len = y.d_pts.*y.n_pts;
  y.x_last     = y.x_first + y.d_ratio.*y.n_pts-1;
  y.x_mid      = y.x_first + y.d_ratio.*round(y.n_pts/2-1/2);
  % generate regular grid data and coordinates for measurements (required only for fft-solver on regular grid)
  aux          = reshape(1:s.npts,[s.n_pts 1]);          % regular grid of s
  switch y.nd
    case 1
      y.midindex = aux(y.x_mid(1));
      aux        = aux(y.x_first(1):y.d_ratio(1):y.x_last(1));
    case 2
      y.midindex = aux(y.x_mid(1),y.x_mid(2));
      aux        = aux(y.x_first(1):y.d_ratio(1):y.x_last(1),...
                       y.x_first(2):y.d_ratio(2):y.x_last(2));
    case 3
      y.midindex = aux(y.x_mid(1),y.x_mid(2),y.x_mid(3));
      aux        = aux(y.x_first(1):y.d_ratio(1):y.x_last(1),...
                       y.x_first(2):y.d_ratio(2):y.x_last(2),...
                       y.x_first(3):y.d_ratio(3):y.x_last(3));
  end
  y.indices    = aux(:);                             % measurement indices in field of unknowns
end

% start up embedding for fft-reg solver
if isequal(options.solver,'fft-reg')
  y.model    = s.model;
  y.variance = s.variance;
  y.lambda   = s.lambda;
  y.nugget   = s.nugget;
  y.micro    = s.micro;
  ye         = find_embedding(y,options);
  Qye1       = generate_covariance_embedded_first_row(y,ye);
end

% generate coordinates for measurements from indices of unknowns
gy.x_pts     = cell(s.nd,1);
for i=1:s.nd
  gy.x_pts{i} = gs.x_pts{i}(y.indices);
end

if isequal(options.solver,'standard') || isequal(options.estvar,'standard')
  Qyy         = generate_covariance_full(s,gy.x_pts); % measurement error is added later
end

%--------------------------------------------
% Setting up blocks for Kriging system of equations
%--------------------------------------------

switch b.model
  case 'zero'
    b.HX     = [];                                      % no additional rows and columns
    b.invQbb = [];                                      % no additional rows and columns
    y.rhs    = y.values;                                % use plain measurement values
    b.rhs    = [];                                      % no additional rows and columns
    b.n      = 0;                                       % ensure that input is correct
  case 'known'
    b.HX     = [];                                      % no additional rows and columns
    b.invQbb = [];                                      % no additional rows and columns
    y.rhs    = y.values-b.beta_pri;                     % subtract known mean from measurement values
    b.rhs    = [];                                      % no additional rows and columns
    b.n      = 0;                                       % ensure that input is correct
  case 'uncertain'
    b.HX     = b.function(y.indices);                   % base function values at measurement locations
    b.invQbb = inv(b.Qbb);                              % invQbb from Qbb
    y.rhs    = y.values;                                % use plain measurement values
    b.rhs    = -b.invQbb*b.beta_pri;                    % additional rows of prior mean coefficients
  case 'unknown'
    b.HX     = b.function(y.indices);                   % base function values at measurement locations
    b.invQbb = zeros([b.n 1]);                          % invQbb is zero
    y.rhs    = y.values;                                % use plain measurement values
    b.rhs    = zeros([b.n 1]);                          % additional rows of zeros
  otherwise
    error('GENERAL_KRIGING.input.b: options for type of mean must be ZERO, KNOWN, UNKNOWN or UNCERTAIN')
end
R            = speye(y.npts)*y.error;                   % measurement error

%--------------------------------------------
% Solve Kriging system of equations
%--------------------------------------------

switch options.solver
  case 'standard'
    [aux1,aux2] = solve_kriging(Qyy ,R,b,y,s.n_pts,options);
  case 'fft-reg'
    [aux1,aux2] = solve_kriging(Qye1,R,b,y,s.n_pts,options);
  case 'fft-irreg'
    [aux1,aux2] = solve_kriging(Qse1,R,b,y,s.n_pts,options);
  otherwise
    error('SOLVE_KRIGING.input.options: solver option must be STANDARD or FFT-REG or FFT-IRREG')
end
switch b.model
  case {'uncertain' 'unknown'}
    Pbb       = - inv(b.HX'*aux2 + b.invQbb);
    beta      = - Pbb * (aux2'*y.rhs + b.invQbb*b.beta_pri);
    ksi       = aux1 - aux2*beta;
  otherwise
    Pbb       = [];
    beta      = [];
    ksi       = aux1;
end
    

%--------------------------------------------
% Evaluating estimator
%--------------------------------------------

% fluctuating part
estimate = superposition(Qse1,ksi,y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);

% base function contributions
switch b.model
  case 'zero'
    % add nothing
  case 'known'
    estimate = estimate + b.beta_pri;
  case 'uncertain'
    estimate = estimate + reshape(b.function*beta,[s.n_pts 1]);
  case 'unknown'
    estimate = estimate + reshape(b.function*beta,[s.n_pts 1]);
  otherwise
    error('EVALUATE_ESTIMATE.input.b: model must be ZERO or KNOWN or UNCERTAIN or UNKNOWN')
end

%--------------------------------------------
% Evaluating estimation variance
%--------------------------------------------

% initializing estimation variance to prior variance
est_var       = ones([s.n_pts 1])*s.variance;

% contributions of the mean value
for i=1:b.n
  Qsy_zi      = superposition(Qse1,aux2(:,i),y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);
  X_i         = reshape(b.function(:,i),[s.n_pts 1]);
  for j=1:b.n
    if i~=j
      Qsy_zj  = superposition(Qse1,aux2(:,j),y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);
      X_i     = reshape(b.function(:,j),[s.n_pts 1]);
    else
      Qsy_zj  = Qsy_zi;
      X_j     = X_i;
    end
    est_var     = est_var - (Qsy_zi-X_i).*Pbb(i,j).*(Qsy_zj-X_j);
  end
end

% dealing with measurement contributions
switch options.estvar
  case 'full'
    for i=1:y.npts
      y.rhs    = unit_vector(y.npts,i);
      switch options.solver
        case 'standard'
          aux1 = solve_kriging(Qyy ,R,b,y,s.n_pts,options,'aux1_only');
        case 'fft-reg'
          aux1 = solve_kriging(Qye1,R,b,y,s.n_pts,options,'aux1_only');
        case 'fft-irreg'
          aux1 = solve_kriging(Qse1,R,b,y,s.n_pts,options,'aux1_only');
      end
      Qsy_i    = shiftaround(Qse1,y.indices(i),s.n_pts,s.nd);
      S_i      = superposition(Qse1,aux1,y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);
      est_var  = est_var - S_i.*Qsy_i;
    end
  case 'one-point'
    Qse1_star       = Qse1.*Qse1;
    y.rhs           = ones([y.npts 1])*s.variance^2/(s.variance+y.error);
      switch options.solver
        case 'standard'
          Qyy_star  = Qyy.*Qyy;
          aux1      = solve_kriging(Qyy_star ,0,b,y,s.n_pts,options,'aux1_only');
        case 'fft-reg'
          Qye1_star = Qye1.*Qye1;
          aux1      = solve_kriging(Qye1_star,0,b,y,s.n_pts,options,'aux1_only');
        case 'fft-irreg'
          aux1      = solve_kriging(Qse1_star,0,b,y,s.n_pts,options,'aux1_only');
      end
    est_star        = superposition(Qse1_star,aux1,y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);
    est_var         = est_var - est_star;
  case 'speedy'
    y.mid_y  = find(y.indices == y.midindex);
    y.rhs    = unit_vector(y.npts,y.mid_y);
    switch options.solver
      case 'standard'
        aux1 = solve_kriging(Qyy ,R,b,y,s.n_pts,options,'aux1_only');
      case 'fft-reg'
        aux1 = solve_kriging(Qye1,R,b,y,s.n_pts,options,'aux1_only');
      case 'fft-irreg'
        aux1 = solve_kriging(Qse1,R,b,y,s.n_pts,options,'aux1_only');
    end
    [X,Se_i] = superposition(Qse1,aux1,y.indices,s.n_pts,se.n_pts,s.nd,options,fftnQse1);
    [X,Se1]  = shiftaround(Se_i,y.midindex,s.n_pts,s.nd,-1);
    Ze1      = Se1.*Qse1;
    clear X Se_i Se1 Qse1 aux1 aux2
    est_star = superposition(Ze1,ones([y.npts 1]),y.indices,s.n_pts,se.n_pts,s.nd,options,real(fftn(Ze1)));
    est_var  = est_var - est_star;
%   case 'hybrid'
%     warning('GENERAL_KRIGING:input','.options: ESTVAR options HYBRID is not implemented yet. Returning NaN.')
%     est_var  = zeros([s.n_pts 1])*NaN; % return all NaN to avoid misinterpretation
  case 'none'
    est_var  = zeros([s.n_pts 1])*NaN; % return all NaN to avoid misinterpretation
  otherwise
    error('GENERAL_KRIGING.input.options: estvar option must be FULL, ONE-POINT, SPEEY or HYBRID')
end

%-----------------------------------------
% plotting the results
%-----------------------------------------

if options.plot == true
  subplot(2,1,1)
  plotter_nd(gs.x_vec{1},gs.x_vec{2},gs.x_vec{3},estimate,'Kriging estimate',[1 1 1],s.n_pts,[],[],2,98,0);
  if ~isempty(est_var) & ~isnan(est_var)
    subplot(2,1,2)
    plotter_nd(gs.x_vec{1},gs.x_vec{2},gs.x_vec{3},est_var,'Kriging variance',[1 1 1],s.n_pts,[],[],2,98,0,[1 0 0]);
  end
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   1
% ----------------------------------------------------------
function [grid_cell] = ndgrid_nd(vec_cell,nd)
% NDGRID_ND evaluates matlab-function NDGRID for all dimensionalities 1-3
% version 01 august 2007 / WN

grid_cell = cell(nd,1);
switch nd
  case 1
    grid_cell{1}  = vec_cell{1}';
    grid_cell{2}  = [];
    grid_cell{3}  = [];
  case 2
    [grid_cell{1},grid_cell{2}]  = ndgrid(vec_cell{1},vec_cell{2});
    grid_cell{3}  = [];
  case 3
    [grid_cell{1},grid_cell{2},grid_cell{3}]  = ndgrid(vec_cell{1},vec_cell{2},vec_cell{3});
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   2
% ----------------------------------------------------------
function [x_pts,x_vec] = generate_grid(n_pts,d_pts,nd)
% GENERATE_GRID generates regular grid from basic grid information
% version 01 august 2007 / WN

% defining domain coordinate vectors
x_vec = cell(nd,1);
for i=1:nd
  x_vec{i}  = (0:n_pts(i)-1)*d_pts(i);
end
for i=nd+1:3
  x_vec{i}  = [];
end

% generating mesh of coordinates
x_pts   = ndgrid_nd(x_vec,nd);

% ----------------------------------------------------------
%   S U B F U N C T I O N   3
% ----------------------------------------------------------
function u = extraction(ue,n_pts,nd)
% EXTRACTION reads smaller result from embedded field
% version 01 august 2007 / WN

switch nd
  case 1
    u = ue(1:n_pts(1));
  case 2
    u = ue(1:n_pts(1),1:n_pts(2));
  case 3
    u = ue(1:n_pts(1),1:n_pts(2),1:n_pts(3));
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   4
% ----------------------------------------------------------
function ue = padding(u,n_pts,n_pts_e,nd)
% PADDING does an embedding in larger field of zeros
% version 01 august 2007 / WN
ue    = zeros([n_pts_e,1]);
switch nd
  case 1
    ue(1:n_pts(1))                       = u;
  case 2
    ue(1:n_pts(1),1:n_pts(2))            = u;
  case 3
    ue(1:n_pts(1),1:n_pts(2),1:n_pts(3)) = u;
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   5
% ----------------------------------------------------------
function ui = injection(u,H,n_pts)
% INJECTION writes values to specified locations into a field of zeros
% version 01 august 2007 / WN

ui    = zeros([n_pts 1]);
ui(H) = u;

% ----------------------------------------------------------
%   S U B F U N C T I O N   7
% ----------------------------------------------------------
function [e] = find_embedding(s,options)
% FIND_EMBEDDING chooses minimum embedding size given grid and geostatistical model
% version 01 august 2007 / WN
%
% required input parameters:
% model_Y      : parametric geostatistical model
% variance_Y   : variance of model
% lambda_Y     : vector of correlation length in y,x,z-direction
% micro_Y      : microscale smoothing parameter relative to lambda_Y
%                (scalar, after Kitanidis book)
% domain_len   : length of domain in y,x,z-direction
% n_el         : number of elements in y,x,z-direction

% finding appropriate size for the embedding (approximately
% ensuring positive definiteness of embedded covariance matrix)
switch s.model
  case 'gaussian'
    e.minsize  = 3 + s.micro;
  case 'exponential'
    e.minsize  = 5 + s.micro;
  case 'spherical'
    e.minsize  = 1 + s.micro;
  otherwise
    error('GENERAL_KRIGING.find_embedding.input: geostatistical model must be GAUSSIAN or EXPONENTIAL or SPHERICAL')
end

% defining embedded domain size
e.n_pts        = ceil(max(s.domain_len,e.minsize.*s.lambda)./s.d_pts + e.minsize*s.lambda./s.d_pts);
e.n_pts        = nicer_primes(e.n_pts,options.maxprime);
e.npts         = prod(e.n_pts);
e.domain_len   = e.n_pts.*s.d_pts;
e.n_add        = e.n_pts      - s.n_pts;
e.domain_add   = e.domain_len - s.domain_len;
e.x_pts        = cell(s.nd,1);

% generate full coordinate grid
e.x_pts       = generate_grid(e.n_pts,s.d_pts,s.nd);

% ...periodicity of distances
for i=1:s.nd
  e.x_pts{i}  = min(e.x_pts{i},e.domain_len(i)-e.x_pts{i});
end

% smoothing the transition at the point of reflection using a microscale smoothing approach
for i=1:s.nd
  e.x_pts{i}  = sqrt((e.domain_len(i)/2).^2+s.lambda(i).^2)  -  sqrt((e.domain_len(i)/2-e.x_pts{i}).^2+s.lambda(i).^2);
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   8
% ----------------------------------------------------------
function Qse1 = generate_covariance_embedded_first_row(s,e)
% GENERATE_COVARIACE_EMBEDDED_FIRST_ROW generates first row of embedded covariance matrix
% version 01 august 2007 / WN

h_eff   = evaluate_separation(e.x_pts,s.lambda,s.micro,s.nd);
Qse1    = evaluate_covariance(s.model,s.variance,s.nugget,h_eff);

% ----------------------------------------------------------
%   S U B F U N C T I O N   9
% ----------------------------------------------------------
function [Qyy] = generate_covariance_full(s,x_pts)
% GENERATE_COVARIANCE_FULL generates full covariance matrix (measurements)
% version 01 august 2007 / WN

% get problem size
npts  = numel(x_pts{1});

% generating coordinate differences between all points
dx_pts = cell(s.nd,1);
for i=1:s.nd
  dx_pts{i} = x_pts{i}*ones(1,npts)-ones(npts,1)*x_pts{i}';
end

% evaluate separation distances and covariance matrix
h_eff = evaluate_separation(dx_pts,s.lambda,s.micro,s.nd);
Qyy   = evaluate_covariance(s.model,s.variance,s.nugget,h_eff);

% ----------------------------------------------------------
%   S U B F U N C T I O N   10
% ----------------------------------------------------------
function Q = evaluate_covariance(model,variance,nugget,h_eff)
% EVALUATE_COVARIANCE evaluates covariance function for a list of separation distances
% version 01 august 2007 / WN

switch model
  case 'gaussian'
    Q        = variance * exp(-h_eff.^2);
  case 'exponential'
    Q        = variance * exp(-h_eff);
  case 'spherical'
    Q        = variance * (1 - 1.5*h_eff + 0.5*h_eff.^3);
    Q(h_eff>1) = 0;
  otherwise
    error('GENERAL_KRIGING.evaluate_covariance.input: geostatistical model must be GAUSSIAN or EXPONENTIAL or SPHERICAL')
end

% adding nugget effect for zero separation distance
if nugget ~= 0
  Q(h_eff==0) = Q(h_eff==0) + nugget;
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   11
% ----------------------------------------------------------
function [h_eff] = evaluate_separation(dx_pts,lambda,micro,nd)
% EVALUATE_SEPARATION evaluates effective separation distance given coordinates differences and scales
% version 01 august 2007 / WN

% evaluating effective separation distance
switch nd
  case 1
    h_eff      = dx_pts{1}/lambda(1);
  case 2
    h_eff      = sqrt((dx_pts{1}/lambda(1)).^2 + (dx_pts{2}/lambda(2)).^2);
  case 3
    h_eff      = sqrt((dx_pts{1}/lambda(1)).^2 + (dx_pts{2}/lambda(2)).^2 + (dx_pts{3}/lambda(3)).^2);
end

% applying microscale smoothing
h_eff        = sqrt(h_eff.^2 + micro.^2)-micro;

% ----------------------------------------------------------
%   S U B F U N C T I O N   12
% ----------------------------------------------------------
function [Qsy_i,Qsye_i] = shiftaround(Qse1,center,n_pts,nd,direction)
% SHIFTAROUND generates single lines of Qsy from first row of embedded Qss
% version 01 august 2007 / WN

if nargin < 5 || isempty(direction)
  direction = +1;
end

switch nd
  case 1
    [k1      ] =               center ;
    Qsye_i     = circshift(Qse1,direction*( k1       -1));
  case 2
    [k1,k2   ] = ind2sub(n_pts,center);
    Qsye_i     = circshift(Qse1,direction*([k1,k2   ]-1));
  case 3
    [k1,k2,k3] = ind2sub(n_pts,center);
    Qsye_i     = circshift(Qse1,direction*([k1,k2,k3]-1));
  otherwise
end
Qsy_i = extraction(Qsye_i,n_pts,nd);


% ----------------------------------------------------------
%   S U B F U N C T I O N   13
% ----------------------------------------------------------
function  [v,ve] = superposition(Qse1,u,H,n_pts,n_pts_e,nd,options,fftnQse1)
% SUPERPOSITION evaluates a superposition by user-specified method
% version 01 august 2007 / WN

if nargin < 8
  fftnQse1 = [];
end

switch options.superpos
  case 'standard'
    m         = numel(H);
    v         = zeros([n_pts 1]);
    for i=1:m
      v_i     = shiftaround(Qse1,H(i),n_pts,nd);
      v       = v + v_i*u(i);
    end
    ve=v;
  case 'fft'
    ui   = injection(u,H,n_pts);              % injection
    ue   = padding(ui,n_pts,n_pts_e,nd);      % embedding
    % convolution via FT
    ve   = fftn(ue);
    if ~isempty(fftnQse1)
      ve = ve .* fftnQse1;
    else
      ve = ve.*fftn(Qse1);
    end
    ve   = ifftn(ve);
    ve   = real(ve);
    v    = extraction(ve,n_pts,nd);           % extraction
  otherwise
    error('SUPERPOSITION.input.options: superposition option must be STANDARD or FFT')
end

% ----------------------------------------------------------
%   S U B F U N C T I O N   14
% ----------------------------------------------------------
function [aux1,aux2] = solve_kriging(Q,R,b,y,n_se,options,flag_aux1_only)
% SOLVE_KRIGING solves Kriging system of equations using user-specified solver
% version 01 august 2007 / WN

if nargin < 7 || isempty(flag_aux1_only)
  flag_aux1_only = 'both';
else
  flag_aux1_only = 'aux1_only';
end  

switch options.solver
  case 'standard'
    if ~isequal(flag_aux1_only,'aux1_only') && (isequal(b.model,'unknown') || isequal(b.model,'uncertain'))
      aux1      = (Q+R)\y.rhs;
      aux2      = (Q+R)\b.HX;
    elseif isequal(b.model,'known') || isequal(b.model,'zero') || isequal(flag_aux1_only,'aux1_only')
      aux1      = (Q+R)\y.rhs;
      aux2      = [];
    end
  case 'fft-reg'
    Q(1)     = Q(1) + R(1);
    if ~isequal(flag_aux1_only,'aux1_only') && (isequal(b.model,'unknown') || isequal(b.model,'uncertain'))
      aux1 = sts_pcg(Q, reshape(y.rhs,[y.n_pts,1]), options.tol, options.maxit, options.cond, options.verbose, options.kalstr, [], options.flag_Strang);
      aux2 = sts_pcg(Q, reshape(b.HX ,[y.n_pts,1]), options.tol, options.maxit, options.cond, options.verbose, options.kalstr, [], options.flag_Strang);
      aux2 = aux2(:);
      aux1 = aux1(:);
    elseif isequal(b.model,'known') || isequal(b.model,'zero') || isequal(flag_aux1_only,'aux1_only')
      aux1 = sts_pcg(Q, reshape(y.rhs,[y.n_pts,1]), options.tol, options.maxit, options.cond, options.verbose, options.kalstr, [], options.flag_Strang);
      aux2 = [];
      aux1 = aux1(:);
    end
  case 'fft-irreg'
    Q(1)     = Q(1) + R(1);
    if numel(n_se) == 1, n_se = [n_se 1]; end
    if ~isequal(flag_aux1_only,'aux1_only') && (isequal(b.model,'unknown') || isequal(b.model,'uncertain'))
      aux1 = gsts_pcg(Q, reshape(y.rhs,y.npts,1), n_se, y.indices, options.tol, options.maxit, options.cond, options.verbose, options.kalstr, []);
      aux2 = gsts_pcg(Q, reshape(b.HX ,y.npts,1), n_se, y.indices, options.tol, options.maxit, options.cond, options.verbose, options.kalstr, []);
      aux2 = aux2(:);
      aux1 = aux1(:);
    elseif isequal(b.model,'known') || isequal(b.model,'zero') || isequal(flag_aux1_only,'aux1_only')
      aux1 = gsts_pcg(Q, reshape(y.rhs,y.npts,1), n_se, y.indices, options.tol, options.maxit, options.cond, options.verbose, options.kalstr, []);
      aux2 = [];
      aux1 = aux1(:);
    end
  otherwise
    error('SOLVE_KRIGING.input.options: solver option must be STANDARD or FFT-REG or FFT-IRREG')
end


% ----------------------------------------------------------
%   S U B F U N C T I O N   15
% ----------------------------------------------------------
function [e_i] = unit_vector(n,i)
% UNIT_VECTOR returns all-zero vector with unit entry at position i
% version 01 august 2007 / WN

e_i    = zeros([n,1]);
e_i(i) = 1;

% -----------------------------------------------------------------
% S U B F U N C T I O N   16
% -----------------------------------------------------------------
function plotter_nd(X,Y,Z,V,name,ratio,vari_size,caxismin,caxismax,percentile_min,percentile_max,symflag,cut)

if isempty(V), delete(gca), return, end
if numel(V) ~= prod(vari_size), delete(gca), return, end
if prod(vari_size)==1, delete(gca), return, end
V = reshape(V,[vari_size 1]);

% assign default value to percentile_min if not provided
if nargin < 10  || isempty(percentile_min)
  percentile_min = 2;
end
% assign default value to percentile_max if not provided
if nargin < 11 || isempty(percentile_max)
  percentile_max = 98;
end
% assign percentile_min value to caxismin if not provided
if nargin < 8 || isempty(caxismin)
  caxismin  = my_prctile(V(:),percentile_min);
end
% assign percentile_max value to caxismax if not provided
if nargin < 9 || isempty(caxismax)
  caxismax  = my_prctile(V(:),percentile_max);
end
% exchange caxismin and caxismax if not a valid interval
if caxismax < caxismin
  caxismin2 = caxismin;
  caxismin  = caxismax;
  caxismax  = caxismin2;
end
% apply unit interval if interval is too small
if caxismax-eps < caxismin
  caxismin = mean([caxismin,caxismax])-0.5; caxismax = caxismin + 1;
end
% force limits symmetric about zero if symflag is set
if nargin > 11 && symflag==1
  caxismin = mean([caxismin,-caxismax]);
  caxismax = -caxismin;
end

% check cutting parameters
if nargin < 13 || isempty(cut)
  cut = [0 0 0];
end
n1           = 1:length(X);
n2           = 1:length(Y);
n3           = 1:length(Z);
if cut(1) == true
  n1         = floor(length(X)/2):length(X);
end
if cut(2) == true
  n2         = floor(length(Y)/2):length(Y);
end
if cut(3) == true
  n3         = 1:floor(length(Z)/2);
end

if length(vari_size)==1
  plot(X,V)
  ylim([caxismin caxismax])
  title(name)
  xlabel('x [m]')
elseif length(vari_size)==2
  pcolor(X,Y,V)
  shading interp
  caxis([caxismin caxismax])
  colorbar
  daspect(ratio)
  set(gcf,'renderer','zbuffer')
  xlabel('x [m]')
  ylabel('y [m]')
  title(name)
elseif length(vari_size)==3
  caxisrng   = abs(caxismax-caxismin);
  levels     = caxismin:caxisrng*0.1:caxismax;
  colors     = round(max(min(1+(levels-caxismin)/caxisrng*63,64),1));

  % handling caxis in case of constant values to be plotted
  if var(V(:)) > eps*eps
    s=slice(X,Y,Z,V,X(end),Y(end),Z(1));
    shading interp
    set(s,'facealpha',0.5)
  end
 
  % plotting isosurfaces of slices depending on noisiness of plots
  noise      = sum(sum(sum(abs(del2(min(max(V,caxismin),caxismax))))))/numel(V)/caxisrng;
  if noise < 0.3 && var(V(:)) > eps*eps
    contourslice(X(n1),Y(n2),Z(n3),V(n2,n1,n3),[X(min(n1)) X(max(n1))],[Y(min(n2)) Y(max(n2))],[Z(min(n3)) Z(max(n3))],levels)
    map=colormap('jet');
    for ii=1:length(levels)
      p=patch(isosurface(X(n1),Y(n2),Z(n3),V(n2,n1,n3),levels(ii)));
      isonormals(X(n1),Y(n2),Z(n3),V(n2,n1,n3),p)
      set(p,'facecolor',map(colors(ii),:),'edgecolor','none','facealpha',0.5);
    end
  elseif var(V(:)) > eps*eps
    slice(X,Y,Z,V,[X(end)/2 X(end)],[Y(end)/2 Y(end)],[0 Z(end)/2])
    hold on
    for i=0:0.5:1
      for j=0:0.5:1
        for k=0:0.5:1
          plot3([0 1]*X(end),[j j]*Y(end),[k k]*Z(end),'k')
          plot3([i i]*X(end),[0 1]*Y(end),[k k]*Z(end),'k')
          plot3([i i]*X(end),[j j]*Y(end),[0 1]*Z(end),'k')
        end
      end
    end
    hold off
    shading interp
  end

  view(-30,25)
  camproj perspective
  daspect(ratio);
  xlims = (X([1 end]));
  ylims = (Y([1 end]));
  zlims = (Z([1 end]));
  xlim(xlims)
  ylim(ylims)
  zlim(zlims)

  a=get(gca,'xtick');
  set(gca,'xtick',a(1:end-1));
  
  camlight left
  camlight head
  lighting phong
  material([0,1,0])

  title(name,'position',[0 50 40],'horizontalalignment','left')
  box on, grid off
  caxis([caxismin caxismax])
  colorbar
  set(gcf,'renderer','opengl')
  xlabel('x [m]','position',[         (xlims(2)-xlims(1))*0.5  , ylims(1)-(ylims(2)-ylims(1))*0.2 , zlims(1)               ])
  ylabel('y [m]','position',[xlims(1)-(xlims(2)-xlims(1))*0.15 ,          (ylims(1)+ylims(2))*0.5 , zlims(1)               ])
  zlabel('z [m]','position',[xlims(1)-(xlims(2)-xlims(1))*0.15 , ylims(2)                         , (zlims(1)+zlims(2))*0.5])
end

% -----------------------------------------------------------------
% S U B F U N C T I O N   17
% -----------------------------------------------------------------
function y = my_prctile(x,p)
% Y = PRCTILE(X,P) returns the P-percentile of the values in the column vector X
% without drawing on statistics toolbox (may not be available on all systems)
% version 16 august 2006 / WN

x      = x(:);
n      = size(x,1);
if n==1
  y    = x;
else
  x      = sort(x,1);
  q      = [0 100*(0.5:(n-0.5))./n 100]';
  xx     = x([1,1:end,end]);
  y      = interp1q(q,xx,p);
end

% -----------------------------------------------------------------
% S U B F U N C T I O N   18
% -----------------------------------------------------------------
function nicer = nicer_primes(number,pmax)
% NICER_PRIMES  looks for a larger number with prime factors
% smaller than pmax. This is useful for optimizing the embedding
% size in spectral methods to make sure the FFT is fast.
% The number is not necessarily the smallest one,
% but tends to be quite close...
%
% NICER = NICER_PRIMES(NUMBER) returns a number NICER >= NUMBER 
% which has nice prime factors. NUMBER must be a scalar, vector
% or matrix with positive integers. 
%
% NICER = NICER_PRIMES(NUMBER,PMAX) specifies the larges allowed
% prime factor in NICER. PMAX must be a single prime number.
% If no pmax is specified, NICER_PRIMES uses the default, PMAX = 7.
%
% Jochen Fritz, 2006.
% Email: jochen.fritz@iws.uni-stuttgart.de
% Version 1.2 by Wolfgang Nowak, 29 June 2007
% Email: wolfgang.nowak@iws.uni-stuttgart.de
%
% New in version 1.1:
% control of input parameters
%
% New in version 1.2:
% restructured code for better human readibility

if nargin < 1
  error('Not enough input arguments!')
end
if nargin > 2
  error('Too many input arguments!')
end
if nargin == 1 || isempty(pmax)
  pmax = 7;  
end
if number ~= round(number) | any(number) <= 0
  error('number must be positive integers')
end
if numel(pmax) ~=1 || pmax < 2 || numel(factor(pmax)) ~= 1
  error('pmax must be a single prime number')
end

nicer           = ones(size(number));
for i = 1:numel(number),
  factors       = factor(number(i));
  while 1==1,
    nicefactors   = factors(factors <= pmax);
    bad_factors   = factors(factors >  pmax);
    nicer(i)    = prod(nicefactors) * nicer(i);
    rest        = prod(bad_factors);
    if rest == 1, break, end
    rest        = rest + 1;
    factors     = factor(rest);
  end
end

% search for possible smaller number based on smaller primes...
if pmax > 2
  pmax2  = max(primes(pmax-1)); % choose next smaller prime below pmax
  nicer2 = nicer_primes(number,pmax2); % check out value
  nicer  = min(nicer,nicer2);
end