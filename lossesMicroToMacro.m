function loss = lossesMicroToMacro(model)

predClasses = model.class.classes';
predClasses = predClasses(:);

trueClasses = double(predictedClassesMicroToMacro(model.trueTestOutput));
predClasses = double(predictedClassesMicroToMacro(predClasses));

if size(trueClasses,1)==1,  trueClasses = trueClasses'; end

oneHotTrueClass = onehotencode(trueClasses,2,'ClassNames',[1 2 3]);
oneHotPredClass = onehotencode(predClasses,2,'ClassNames',[1 2 3]);

loss = crossentropy(oneHotPredClass,oneHotTrueClass);


