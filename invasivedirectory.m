
directoryname = 'C:\Users\corneyr\OneDrive - University of Tasmania\Honours 2023\HonoursCode\Data\InvasiveBP';

filenames = dir(directoryname);

for i = 1:length(filenames)
    if filenames(i).name ~= "." && filenames(i).name ~= ".."
         path = directoryname + "\" + filenames(i).name;
         disp(path)
         fh = plotinvasive(path);
    end
end

