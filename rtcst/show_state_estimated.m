function show_state_estimated(s, b, F_k)

x1 = b(1); x2 = b(1)+b(3);
y1 = b(2); y2 = b(2)+b(4);
u = [x1 x2 x2 x1 x1];
v = [y1 y1 y2 y2 y1];
tform = affine2d([s(1) s(2) 0; s(3) s(4) 0; s(5) s(6) 1]);
[x, y] = transformPointsForward(tform, u, v);

figure(1);
imshow(F_k);
hold on;
plot(x, y, 'Color', [1 0 0], 'LineWidth', 2);
hold off;
drawnow;

end
