% Name: plot the curve with time
% Author: Yanyu Zhu, 7-20-24
% How to use: choose your csv file and it will generate the final video in
% mp4 format
PathName = fileparts(matlab.desktop.editor.getActiveFilename);
[FileName, PathName] = uigetfile({'*.csv';'*.*'},'Open registered file', PathName);
cd(PathName);
curve=readtable(FileName);
%%
aa=table2array(curve);
figure
time=aa(:,1);   
intensity=aa(:,2);
plot(time, intensity,'g');   % this is to check the plot

f = figure(13);
f.Position = [292,70,1217,896];
f.Color = 'w';
ax = axes(f);
xlim(ax, [0,250]);
ylim(ax, [0,6]);
fontsize(ax, 35,"points");
ax.LineWidth = 2;
% pause(1);

for i = 1 : size(time,1)
    plot(ax, time(1:i),intensity(1:i),'g',LineWidth = 3);   % g stands for green, r for red, b for blue, you can change color here
    xlabel(ax, 'time after adding ABA (minute)');  % change your label according to the axis name everytime
    ylabel(ax, ['Intensity of dCas13 at the neunite tip (arb. unit)']);
    xlim(ax, [0,250]);
    ylim(ax, [0,6]);
    fontsize(ax, 30,"points");  % change the font size here
    ax.LineWidth = 2;  % change the axis width
    pause(0.01);
    drawnow;
    F(i) = getframe(f);
    %hold on;
end
%%
% write video file
[filename,PathName]=uiputfile({'*.mp4', 'Video File (*.mp4)'; '*.*',  'All Files (*.*)'}, 'Save as', PathName);
v = VideoWriter([PathName filename],'MPEG-4'); %file name to record, h264 encoding
v.Quality = 100; %video quality (from 0 to 100)
v.FrameRate = 50; %frame rate; more options: https://www.mathworks.com/help/matlab/ref/videowriter.html
open(v);
for i = 1:numel(F)
    writeVideo(v,F(i).cdata);
end
close(v);