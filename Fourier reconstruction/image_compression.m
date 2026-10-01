function [image_compressed] = image_compression(image,compression_factor)
%% image compression
[rows columns levels] = size(image);
rimage = image(:,:,1);
gimage = image(:,:,2);
bimage = image(:,:,3);


% GAUSSIAN BLUR %
blur_coeff = 0.5;
blur_scale = 0;
if blur_scale == ~0
    blurmat = zeros(blur_scale);
    blurmat((blur_scale+1)/2,(blur_scale+1)/2) = blur_coeff;
end
%%
crows = fix(rows/compression_factor);
ccolumns = fix(columns/compression_factor);
rgbimage = {rimage gimage bimage};
% rgbimage_compressed{1} = zeros(crows,ccolumns);
% rgbimage_compressed{2} = zeros(crows,ccolumns);
% rgbimage_compressed{3} = zeros(crows,ccolumns);
for r = 1:3
    if compression_factor/2 == fix(compression_factor/2)
        mstart = 1;
        mend = rows-compression_factor+1;
        nstart = 1;
        nend = columns - compression_factor+1;
            for m = mstart:compression_factor:mend
                for n = nstart:compression_factor:nend
                    compmat = rgbimage{r}(m:(m+compression_factor-1),n:(n+compression_factor-1));
                    compval = fix(sum(compmat(:))/length(compmat(:)))/255;
                    if n==1 && m==1
                        rgbimage_compressed{r}(1,1) = compval;
                    elseif m == 1
                        rgbimage_compressed{r}(1,(n-1)/compression_factor+1) = compval;
                    elseif n ==1
                        rgbimage_compressed{r}((m-1)/compression_factor+1,1) = compval;
                    else
                        rgbimage_compressed{r}((m-1)/compression_factor+1,(n-1)/compression_factor+1) = compval;
                    end
                end
            end
    else
        mstart = (compression_factor-1)/2 + 1;
        nstart = mstart;
        d = (compression_factor-1)/2;
        mend = rows - d;
        nend = columns - d;
       q = 0;
       z = 0;
            for m = mstart:compression_factor:mend
                z = z + 1;
                for n = nstart:compression_factor:nend
                    q = q + 1;
                    compmat = rgbimage{r}(m-d:m+d,n-d:n+d);

                    compval = fix(sum(compmat(:))/length(compmat(:)))/255;
                    if m == mstart && n == nstart
                        rgbimage_compressed{r}(1,1) = compval;
                    elseif m == mstart
                         rgbimage_compressed{r}(1,q) = compval;
                    elseif n == nstart
                         rgbimage_compressed{r}(z,1) = compval;
                    else
                        rgbimage_compressed{r}(z,q) = compval;

                    end
                    if n >= nend-2*d
                        q = 1;
                    end
                end
                if z >= mend-2*d
                    z = 1;
                end
            end
    end
    if blur_coeff == 0
        break
    end
    for m = 1:rows
        for n = columns
        
        end
    end

end
for r = 1:3
    for m = mstart:compression_factor:mend
        for n = nstart:compression_factor:nend

        end
    end
end

for m = 1:rows
    for n = columns

    end
end


empty = zeros(rows,columns);
image_compressed = cat(3,rgbimage_compressed{1},rgbimage_compressed{2},rgbimage_compressed{3});

