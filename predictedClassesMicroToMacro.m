function classesMacro = predictedClassesMicroToMacro(classesMicro)

classesMicro = categorical(classesMicro);

firstClass = categorical(1:2);
secondClass = categorical(3:8);
thirdClass = categorical(9:11);

classesMacro = classesMicro;

classesMacro(ismember(classesMicro,firstClass)) = categorical(1);
classesMacro(ismember(classesMicro,secondClass)) = categorical(2);
classesMacro(ismember(classesMicro,thirdClass)) = categorical(3);