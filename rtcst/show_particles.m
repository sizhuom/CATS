function show_particles(S, b, F_k)

x = S(5, :) + b(1) + b(3)/2;
y = S(6, :) + b(2) + b(4)/2;

figure(1);
imshow(F_k);
hold on;
plot(x, y, '.', 'Color', [1 0 0], 'LineWidth', 0.5);
hold off;
drawnow;

end