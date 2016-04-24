function S = create_particles(num_particles, b)

I = [ 1 0 0 1 b(1)-1 b(2)-1 ]';
S = repmat(I, 1, num_particles);
