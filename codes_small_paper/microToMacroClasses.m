function [train, val, test, settings] = microToMacroClasses(train,val,test,settings)

train.output = double(train.output);
val.output = double(val.output);
test.output = double(test.output);

train.output(train.output>=1 & train.output<=2) = 1;
train.output(train.output>=3 & train.output<=8) = 2;
train.output(train.output>=9 & train.output<=11) = 3;
val.output(val.output>=1 & val.output<=2) = 1;
val.output(val.output>=3 & val.output<=8) = 2;
val.output(val.output>=9 & val.output<=11) = 3;
test.output(test.output>=1 & test.output<=2) = 1;
test.output(test.output>=3 & test.output<=8) = 2;
test.output(test.output>=9 & test.output<=11) = 3;

train.output = categorical(train.output);
val.output = categorical(val.output);
test.output = categorical(test.output);

settings.classes = 1:3;