function show_particles(S, L, b, F_k)

x = S(5, :) + b(1) + b(3)/2;
y = S(6, :) + b(2) + b(4)/2;
L = L / max(L);

figure(1);
imshow(F_k);
hold on;
for i = 1:length(x)
    c = [1 0 0] * L(i) + [0 1 0] * (1-L(i));
    plot(x(i), y(i), '.', 'Color', c, 'LineWidth', 0.5);
end
hold off;
drawnow;

end