%% Setup
clear all;
close all;
clc;
format long;
name = 'Max_lemieux';
id = 'A19078801';
hw_num = 2;
s = settings;
s.matlab.appearance.figure.GraphicsTheme.TemporaryValue = "light";

%% Image selection and settings
files = dir('Images\');
num = size(files);
for n = 3:num(1)
    filename{n-2} = files(n).name;
end
option = menu('Select image', filename);
image = ['Images\' filename{option}];
image = imread(image);
skip = menu('Want to see only the final image? (can set harmonics to > 54,000)', 'Step by step', 'Final');
switch skip
    case 1
        comp = inputdlg('Compression amount, 5-15 recommended (higher => lower resolution)');
    case 2
        comp = inputdlg('Compression amount, 2-5 recommended (higher => lower resolution)');
end
x = msgbox('Setting up, please wait...');
pause(0.1)
% harmonics{1} = '600000';
% comp = 1;
% colors = true;

%% Compression and layer separation
image = image_compression(image,str2num(comp{1}));
rmax = max(max(image(:,:,1)));
gmax = max(max(image(:,:,2)));
bmax = max(max(image(:,:,3)));
rgbimage{1} = image(:,:,1)/rmax;
rgbimage{2} = image(:,:,2)/gmax;
rgbimage{3} = image(:,:,3)/bmax;
[rows cols] = size(rgbimage{1});

%% fft values calc
for r = 1:3
    fftimage{r} = fftshift(fft2(rgbimage{r}));
    fftmag{r} = abs(fftshift(fft2(rgbimage{r})));
    phase{r} = angle(fftshift(fft2(rgbimage{r})));
end

%% Ordering fft values by distance from center
center = [ceil(rows/2) ceil(cols/2)];
temp = zeros(rows,cols);
for m = 1:rows
    for n = 1:cols
        temp(m,n) = sqrt((n-center(2))^2 + (m-center(1))^2);
        temp2{m,n} = [m n];
    end
end
halftemp = temp(:,center(2):end);
[order index] = sort(temp(:),"ascend");
orderedpos = zeros(6,length(halftemp(:)),3);
q = 0;
for n = 1:length(index)
    if temp2{index(n)}(2) < center(2)
        continue
    else
        if temp2{index(n)}(1) > center(1) && temp2{index(n)}(2) == center(2)
            continue
        else
            q = q + 1;
            for r = 1:3
                orderedpos(1,q,r) = temp2{index(n)}(1);
                orderedpos(2,q,r) = temp2{index(n)}(2);
                orderedpos(3,q,r) = fftimage{r}(temp2{index(n)}(1),temp2{index(n)}(2));
                if 2*center(1)-temp2{index(n)}(1) == 0 && 2*center(2)-temp2{index(n)}(2) == 0
                    orderedpos(4,q,r) = 2*center(1)-temp2{index(n)}(1)+1;
                    orderedpos(5,q,r) = 2*center(2)-temp2{index(n)}(2)+1;
                elseif 2*center(1)-temp2{index(n)}(1) == 0
                    orderedpos(4,q,r) = 2*center(1)-temp2{index(n)}(1)+1;
                    orderedpos(5,q,r) = 2*center(2)-temp2{index(n)}(2);
                elseif 2*center(2)-temp2{index(n)}(2) == 0
                    orderedpos(4,q,r) = 2*center(1)-temp2{index(n)}(1);
                    orderedpos(5,q,r) = 2*center(2)-temp2{index(n)}(2)+1;
                else                    
                    orderedpos(4,q,r) = 2*center(1)-temp2{index(n)}(1);
                    orderedpos(5,q,r) = 2*center(2)-temp2{index(n)}(2);
                end
                orderedpos(6,q,r) = fftimage{r}(orderedpos(4,q,r),orderedpos(5,q,r));
            end
        end
    end
end
delete(x)

switch skip
    case 1
        harmonics = inputdlg('Input number of harmonics to calculate (500 - 5000 recommended)');
        colors = menu('Color?', 'Color', 'Black and White');
    case 2
        harmonics = inputdlg(sprintf('Input number of harmonics to calculate, max value = %d (10,000 - 50,000 recommended)',q));
        colors = menu('Color?', 'Color', 'Black and White');
end


%% display
hold on
itterations = str2num(harmonics{1});
soloRGB  = zeros(rows, cols,3);
waveRGB  = soloRGB;
singlewave = zeros(rows,cols);
epoch = zeros(rows,cols);
tic;
%m = 100
color = colors;
if skip == 1
    if color == true
            for n = 1:3
                epoch(:,:,n) = zeros(rows,cols);
            end
            anim = imshow(epoch);
        for m = 1:itterations
            for r = 1:3
                epoch(orderedpos(1,m,r),orderedpos(2,m,r),r) = orderedpos(3,m,r);
                epoch(orderedpos(4,m,r),orderedpos(5,m,r),r) = orderedpos(6,m,r);
                waveRGB(:,:,r) = abs(ifft2(epoch(:,:,r)));
            end
            set(anim, 'CData', waveRGB)
            drawnow limitrate
            sgtitle(sprintf('%dth Harmonic',m))
        end
    else
        epoch = zeros(rows,cols);
        singlewave = zeros(rows,cols);
        subplot(1,2,2)
        anim = imshow(epoch);
        subplot(1,2,1)
        sing = imshow(singlewave);
        for m = 1:itterations
            tic;
             singlewave(orderedpos(1,m,r),orderedpos(2,m,r),1) = orderedpos(3,m,1);
             singlewave(orderedpos(4,m,r),orderedpos(5,m,r),1) = orderedpos(6,m,1);
             solo = abs(ifft2(singlewave));
             solo = (solo./max(solo(:)));
             soloRGB(:,:,1) = solo;
             soloRGB(:,:,2) = solo;
             soloRGB(:,:,3) = solo;

             epoch(orderedpos(1,m,r),orderedpos(2,m,r),1) = orderedpos(3,m,1);
             epoch(orderedpos(4,m,r),orderedpos(5,m,r),1) = orderedpos(6,m,1);
             wave = abs(ifft2(epoch));
             wave = (wave./max(wave(:)));
             waveRGB(:,:,1) = wave;
             waveRGB(:,:,2) = wave;
             waveRGB(:,:,3) = wave;

             set(anim, 'CData', wave)
             set(sing, 'CData', solo)
             sgtitle(sprintf('%dth Harmonic',m))
             drawnow limitrate

             singlewave(orderedpos(1,m,r),orderedpos(2,m,r),1) = 0;
             singlewave(orderedpos(4,m,r),orderedpos(5,m,r),1) = 0;

             %pause(exp(-m/10))
            t = toc;
        end
    end
else
    if color == true
            for n = 1:3
                epoch(:,:,n) = zeros(rows,cols);
            end
            anim = imshow(epoch);
        for m = 1:itterations
            for r = 1:3
                epoch(orderedpos(1,m,r),orderedpos(2,m,r),r) = orderedpos(3,m,r);
                epoch(orderedpos(4,m,r),orderedpos(5,m,r),r) = orderedpos(6,m,r);
            end
        end
        waveRGB(:,:,1) = abs(ifft2(epoch(:,:,1)));
        waveRGB(:,:,2) = abs(ifft2(epoch(:,:,2)));
        waveRGB(:,:,3) = abs(ifft2(epoch(:,:,3)));
        set(anim, 'CData', waveRGB)
        drawnow limitrate
        sgtitle(sprintf('%dth Harmonic',m))
        figure
        imagesc(log(abs(epoch(:,:,1))))

    else
        epoch = zeros(rows,cols);
        singlewave = zeros(rows,cols);
        sing = imshow(singlewave);
        for m = 1:itterations

             singlewave(orderedpos(1,m,r),orderedpos(2,m,r),1) = orderedpos(3,m,1);
             singlewave(orderedpos(4,m,r),orderedpos(5,m,r),1) = orderedpos(6,m,1);

             epoch(orderedpos(1,m,r),orderedpos(2,m,r),1) = orderedpos(3,m,1);
             epoch(orderedpos(4,m,r),orderedpos(5,m,r),1) = orderedpos(6,m,1);

        end
             wave = abs(ifft2(epoch));
             wave = (wave./max(wave(:)));
             waveRGB(:,:,1) = wave;
             waveRGB(:,:,2) = wave;
             waveRGB(:,:,3) = wave;

             solo = abs(ifft2(singlewave));
             solo = (solo./max(solo(:)));
             soloRGB(:,:,1) = solo;
             soloRGB(:,:,2) = solo;
             soloRGB(:,:,3) = solo;

             set(sing, 'CData', solo)
             sgtitle(sprintf('%dth Harmonic',m))
             drawnow limitrate
    end
end