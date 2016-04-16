function show_box( F, b )
%SHOW_BOX: show bounding box on the frame

imshow(F);
hold on;
x1 = b(1);
x2 = b(1) + b(3);
y1 = b(2);
y2 = b(2) + b(4);
plot([x1 x2 x2 x1 x1], [y1 y1 y2 y2 y1], 'Color', [1 0 0], 'LineWidth', 2);

end

