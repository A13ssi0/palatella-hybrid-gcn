function classesMacro = predictedClassesMicroToMacro(classesMicro)

firstClass = categorical(1:2);
secondClass = categorical(3:8);
thirdClass = categorical(9:11);

classesMacro = classesMicro;

classesMacro(classesMicro==firstClass) = categorical(1);
classesMacro(classesMicro==secondClass) = categorical(2);
classesMacro(classesMicro==thirdClass) = categorical(3);