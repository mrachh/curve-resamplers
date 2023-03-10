%driver 
clear

%boundaydx
N_bd             = 3;
coefs_bd         = zeros(1,2*N_bd+1);
coefs_bd(1)      = 2.;
coefs_bd(N_bd+1) = 0.;


n_bd = 200;
t_bd  = 0:2*pi/n_bd:2*pi-2*pi/n_bd;
h_bd  = 2*pi/n_bd ;   
c_t   = cos(t_bd);
s_t   = sin(t_bd);
p_t   = (coefs_bd(1)+cos(bsxfun(@times,t_bd',1:N_bd))*coefs_bd(2:N_bd+1)'+...
    sin(bsxfun(@times,t_bd',1:N_bd))*coefs_bd(N_bd+2:end)')';
dp_t  = (bsxfun(@times,(1:N_bd)',-sin(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(2:N_bd+1)' + ...
    bsxfun(@times,(1:N_bd)',cos(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(N_bd+2:end)')';
d2p_t = (bsxfun(@times,((1:N_bd).*(1:N_bd))',-cos(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(2:N_bd+1)' + ...
    bsxfun(@times,((1:N_bd).*(1:N_bd))',-sin(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(N_bd+2:end)')';
d3p_t = (bsxfun(@times,((1:N_bd).*(1:N_bd).*(1:N_bd))',sin(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(2:N_bd+1)' + ...
    bsxfun(@times,((1:N_bd).*(1:N_bd).*(1:N_bd))',-cos(bsxfun(@times,(1:N_bd)',t_bd)))'*coefs_bd(N_bd+2:end)')';
xs    = p_t .* c_t;
ys    = p_t .* s_t;
dxs   = dp_t .* c_t + p_t .* (-s_t);
dys   = dp_t .* s_t + p_t .* c_t;
d2xs  = d2p_t .* c_t + 2 * dp_t .* (-s_t) + p_t .* (-c_t);
d2ys  = d2p_t .* s_t + 2 * dp_t .* c_t + p_t .* (-s_t);    
d3xs  = d3p_t .* c_t + d2p_t .*(-s_t) - 2 * (d2p_t .* s_t + dp_t .* c_t) - (dp_t .*c_t + p_t .*(-s_t));
d3ys  = d3p_t .* s_t + d2p_t .* c_t + 2 * (d2p_t .* c_t - dp_t .* s_t) - (dp_t .* s_t + p_t .* c_t);
ds    = sqrt(dxs.^2 + dys.^2);
H     = ( dxs .* d2ys - dys .* d2xs )  ./ ( ds.^3 );
L     = length(ds)*h_bd;  

var_up        = zeros(1,2*N_bd+1);    
var_up(1) = 0;
var_up(4) = 0.1;
src_info      = zeros(5,n_bd);
src_info(1,:) = xs;
src_info(2,:) = ys;
src_info(3,:) = dys./ds;
src_info(4,:) = -dxs./ds;
src_info(5,:) = ds;    
% src_old = src_info;
[srcout,hout,Lout,~,tt] = resample_curve(src_info,L,N_bd,var_up',n_bd);   
h_bd = hout;
L    = Lout;
xs1   = srcout(1,:);
ys1   = srcout(2,:);
ds1   = srcout(5,:);
dxs1  = -srcout(4,:).*srcout(5,:);
dys1  = srcout(3,:).*srcout(5,:);
src_info1     = srcout;
err = max(abs(srcout(1,:) - (2+var_up(1)+var_up(4)*cos(3*tt')).*cos(tt')));
fprintf('Error in x-coordinate: %d\n',err);
err = max(abs(srcout(2,:) - (2+var_up(1)+var_up(4)*cos(3*tt')).*sin(tt')));
fprintf('Error in y-coordinate: %d\n',err);
dht = -3*var_up(4)*sin(3*tt');
dxs = dht .*cos(tt')-(2+var_up(1)+var_up(4)*cos(3*tt')).*sin(tt');
dys = dht .*sin(tt')+(2+var_up(1)+var_up(4)*cos(3*tt')).*cos(tt');
ds  = sqrt(dxs.^2+dys.^2);

err = max(abs(srcout(3,:) - dys./ds));
fprintf('Error in x normal: %d\n',err);
err = max(abs(srcout(4,:) - (-dxs./ds)));
fprintf('Error in y normal: %d\n',err);
