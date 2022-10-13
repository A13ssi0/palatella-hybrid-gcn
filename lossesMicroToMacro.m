function loss = lossesMicroToMacro(model)

predClasses = model.class.classes';
predClasses = predClasses(:);

trueClasses = predictedClassesMicroToMacro(model.trueTestOutput);
predClasses = predictedClassesMicroToMacro(predClasses);

oneHotTrueClass = oneHotEncodingClasses(trueClasses);
oneHotPredClass = oneHotEncodingClasses(predClasses);

loss = crossentropy(oneHotPredClass,oneHotTrueClass);


