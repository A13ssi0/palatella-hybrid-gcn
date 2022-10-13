function oneHotEncoded = oneHotEncodingClasses(classesColumn)

class = unique(classesColumn)';
oneHotEncoded = nan(length(classesColumn),length(class));

for i = class
    oneHotEncoded(classesColumn==categorical(i),i) = 1;
end
