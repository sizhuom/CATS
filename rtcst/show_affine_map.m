function show_affine_map( y, b )
%SHOW_AFFINE_MAP

img = reshape(y, b(4), b(3));
imshow(img);

end

