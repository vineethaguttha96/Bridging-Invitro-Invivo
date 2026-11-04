% calculate and plot msd and rms
% plot and save cell trajectory, rose plot, forward index
% save cell rmc, area, aspect ratios into excel file
% author: Jay Hou, houxx149@umn.edu
% 20230331: user choose the folder, and the program can read all text files inside
% 20230331: add y limit for forward migration index

clear all;
close all;

[folder, name, ext] = fileparts( mfilename('fullpath'));
cd(folder);

pix=644;%nm%10X = 500um/772pix = 500/772*1000 = 648nm/pix, 20X = (330)
dt = 10; %min
fontsize = 15;
saveTF = 1;

selectfolder=uipickfiles;
%  file_mat = {'C:\Users\ryanc\Dropbox\1SarahChen-Jay\20230220_collagen\dy0_8.mat'};

cd(selectfolder{1})
dinfo = dir('*.txt');

for i = 1:length(dinfo)
    file_cell{i} = [selectfolder{1} '/' dinfo(i).name];
   
end

cd(folder)


% load(file_mat{1})

% file_cell = {'/Users/jayhou/Documents/1aexp/20230220_collagen/Cell_Tracking/col2mgmlu251gfprod011-maxipc2-1 copy.tif kept stack_1.txt','/Users/jayhou/Documents/1aexp/20230220_collagen/Cell_Tracking/col2mgmlu251gfprod011-maxipc2-1 copy.tif kept stack_2.txt','/Users/jayhou/Documents/1aexp/20230220_collagen/Cell_Tracking/col2mgmlu251gfprod011-maxipc2-1 copy.tif kept stack_3.txt','/Users/jayhou/Documents/1aexp/20230220_collagen/Cell_Tracking/col2mgmlu251gfprod011-maxipc2-1 copy.tif kept stack_4.txt'};
[Filepath,Filename,Fileext] = fileparts(file_cell{1});

%% plot cell msd

gcf = figure('Position',[500,200,800,300]);%[x,y,dx,dy]

msd_v=zeros(100,numel(file_cell));
sem_v=zeros(100,numel(file_cell));
maxa=0;
for i=1:numel(file_cell)
    data=load(char(file_cell(i)));
    %data = cell number, area, posx, posy, axis_min, axis_max
    [frameno b]=size(data);
    if frameno>maxa; maxa=frameno; end
    msd=zeros(1,frameno-1);
    sem=zeros(1,frameno-1);
    for j=1:frameno-1
        xdif=[];
        ydif=[];
        for k=1:frameno-j %step through every interval of the determined size
            xdif(k)=(data(k+j,3)-data(k,3))*pix;%nm
            ydif(k)=(data(k+j,4)-data(k,4))*pix;%nm
        end
        sqdisp=[xdif.^2+ydif.^2];
        sqdisp(isnan(sqdisp))=[];
        msd(j)=mean(sqdisp);
        sem(j)=std(sqdisp)/(numel(sqdisp)^0.5);
    end
    
    t=dt*[1:frameno-1];
    
    msd(sem==0)=[];
    t(sem==0)=[];
    sem(sem==0)=[];
    
    msd(isnan(sem))=[];
    t(isnan(sem))=[];
    sem(isnan(sem))=[];
    
    msd=msd*10^-6; %convert nm^2 to um^2
    sem=sem*10^-6;
    
    [D,R]=fminunc(@(D) randwalk(D,t,msd,sem),[1]);
    [P,S]=fminunc(@(P) prandwalk(P,t,msd,sem),[1 1]);
    
    rmc(i)=D;
    pers(i)=P(2);
    speed(i)=P(1);
%     figure; 
%     subplot(2,1,1); hist((data(:,2))*((pix)/1000)^2);
%     subplot(2,1,2); hist((data(:,6)./data(:,5)));
    cellarea(i)=nanmean(data(:,2))*((pix)/1000)^2;
    cellar(i)=nanmean(data(:,6)./data(:,5));
    subplot(1,2,1);
    plot(t,msd)
    hold on
    xlabel('time (min)')
    ylabel('msd (um2)')
    
    dx=(data(:,3)-data(1,3))*pix*10^-3;%um, pos dx is to right
    dy=(data(:,4)-data(1,4))*pix*10^-3*-1;% pos dy to down
    dx(isnan(dx))=[];
    dy(isnan(dy))=[];
    cell_dx{i} = dx;
    cell_dy{i} = dy;
    
    cell_dyend(i) = dy(end);
    
    temp_path = 0;
    for j = 1:length(dx)-1
        temp_dx = dx(j+1)-dx(j);
        temp_dy = dy(j+1)-dy(j);
        temp_dl = sqrt(temp_dx^2+temp_dy^2);
        temp_path = temp_path + temp_dl;
    end
    
    cell_pathl(i) = temp_path;
    
    cell_angle(i) = atan2d(dy(end),dx(end));%degrees
    
    msd_v(1:length(msd),i)=msd';
    sem_v(1:length(msd),i)=sem';
end
msd_v(msd_v==0)=nan;
sem_v(sem_v==0)=nan;
mean(rmc)
std(rmc)/(numel(rmc)^0.5)
mean_msd=nanmean(msd_v,2);
mean_msd=mean_msd(~isnan(mean_msd));
sem_msd_gs=(nanmean(sem_v.^2,2)).^0.5;
sem_msd_gs=sem_msd_gs(~isnan(sem_msd_gs));
sem_msd_bb=((nansum(sem_v.^2,2)).^0.5)./sum(~isnan(sem_v),2);
sem_msd_bb= sem_msd_bb(~isnan(sem_msd_bb));
sem_msd=nanstd(msd_v')'./(sum(~isnan(msd_v),2)).^0.5;
sem_msd=sem_msd(~isnan(sem_msd));

plot([15:15:15*length(mean_msd)], mean_msd, 'r', 'LineWidth',4); 

subplot(1,2,2);
plot([dt:dt:dt*length(mean_msd)], mean_msd, 'b'); 
hold on; plot([dt:dt:dt*length(mean_msd)], 4*[dt:dt:dt*length(mean_msd)]*mean(rmc), 'r');

%% analysis plot
gcf = figure('Position',[500,0,800,800]);
subx = [0.1 0.4 0.7];
suby = [0.77 0.1];
subwh = [0.2 0.2];

%% trajectory

limitN = 100;
x_limit = [-limitN limitN];
y_limit = [-limitN limitN];
x_lable = 'position (um)';
y_lable = 'position (um)';

h = subplot('Position',[subx(1) suby(1) subwh(1) subwh(2)]);

for i = 1:length(cell_dx)
    
    dx = cell_dx{i};
    dy = cell_dy{i};
    
    plot(dx,dy,'b');hold on
    plot(dx(end),dy(end),'*b')
    
end

% circle
% rmsd=(4*mean(rmc)*dt*maxa)^0.5;
% theta=linspace(0,2*pi);
% xcirc=rmsd*cos(theta);
% ycirc=rmsd*sin(theta);
% plot(xcirc,ycirc,'-r')



xlim(x_limit);%axis square,
xticklabels([]);xtickangle(45);
xlabel(x_lable);

ylim(y_limit);%axis square,
% yticks(y_ticks);ytickangle(0);
% yticklabels(y_ticklabel)
ylabel(y_lable)
% lgd = legend(dataName,'Location','northeast','FontSize',10);%'NumColumns',5
set(gca,'FontSize',fontsize);%font size = 20

%% rose plot

limitN = 20;
x_limit = [-limitN limitN];
y_limit = [-limitN limitN];
x_lable = 'position (um)';
y_lable = 'position (um)';
fontsize = 15;
nbins = 10;

h = subplot('Position',[subx(2) suby(1) subwh(1) subwh(2)]);

rose(cell_angle./180*pi,nbins)


xlim(x_limit);%axis square,
xticklabels([]);xtickangle(45);
xlabel(x_lable);

ylim(y_limit);%axis square,
% yticks(y_ticks);ytickangle(0);
% yticklabels(y_ticklabel)
ylabel(y_lable)
% lgd = legend(dataName,'Location','northeast','FontSize',10);%'NumColumns',5
set(gca,'FontSize',fontsize);%font size = 20

%% forwward migration indices

binsize = 0.1;
x_limit = [-1 1];
y_limit = [-0.2 0.2];
y_lable = 'FMI';%forward migraiton indices
text_xy = [0.1 0.2];

h = subplot('Position',[subx(3) suby(1) subwh(1) subwh(2)]);


y_arr = cell_dyend./cell_pathl;

x_arr = zeros(length(y_arr),1);

% plot violin plot
bin = [min(y_arr)-binsize:binsize:max(y_arr)+binsize];
for i = 1:length(bin)-1
    ind_bin = find(y_arr >= bin(i) & y_arr < bin(i+1));
    ind_binN = length(ind_bin);
    str_temp = [1:ind_binN];
    x_arr(ind_bin) = (str_temp-mean(str_temp))./length(y_arr);
end

% plot(x_arr,y_arr,'.','MarkerSize',10,'Color',curveColor(dataN,:));hold on;
plot(x_arr,y_arr,'.','MarkerSize',10);hold on;

xlim(x_limit);%axis square,
% xticklabels([]);xtickangle(45);
ylim(y_limit);%axis square,
% yticks(y_ticks);ytickangle(0);
% yticklabels(y_ticklabel)
ylabel(y_lable)
set(gca,'FontSize',fontsize);%font size = 20

% statistics
p = signrank(y_arr)


text_text = ['p = ' num2str(p,2)];
% h=text(text_xy,text_text,'Color',curveColor(dataN,:),'fontsize',fontsize,'Rotation',90);
h=text(text_xy(1),text_xy(2),text_text,'fontsize',fontsize);



% % annotate
% an_xy = [subx(3)+0.3 0.6 1 0.01];
% an_text = ['p = ' num2str(p)];
% annotation('textbox',an_xy,'String',an_text,'FontSize',10,'EdgeColor','none');


%% save

tempcell{1,1} = 'rmc(um^2/min)';
tempcell{1,2} = 'area(um^2)';
tempcell{1,3} = 'aspect ratio';

cellarea=cellarea';
cellar=cellar';
rmc=rmc';

for i = 1:length(rmc)
   tempcell{i+1,1} = rmc(i);
   tempcell{i+1,2} = cellarea(i);
   tempcell{i+1,3} = cellar(i);
    
end

[selectpath,selectname,Fileext] = fileparts(selectfolder);

name_save = [selectname '.xlsx'];
T = cell2table(tempcell);
writetable(T,name_save)


%% save plot
if saveTF == 1
plot_save = [selectname '.png'];

saveas(gcf,plot_save)


close all
I = imread(plot_save);
[I2, rect] = imcrop(I);
imshow(I2) ;
imwrite(I2,plot_save)

end


