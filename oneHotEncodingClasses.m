function oneHotEncoded = oneHotEncodingClasses(classesColumn)

class = unique(classesColumn)';
oneHotEncoded = zeros(length(classesColumn),length(class));

for i = class
    oneHotEncoded(classesColumn==categorical(i),double(i)) = 1;
end
