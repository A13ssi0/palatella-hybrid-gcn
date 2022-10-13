function loss = computeLossFromModel(model)

predClasses = model.class.classes';

predClasses = predClasses(:);
trueClasses = model.trueTestOutput;

oneHotTrueClass = oneHotEncodingClasses(trueClasses);
oneHotPredClass = oneHotEncodingClasses(predClasses);

loss = crossentropy(oneHotPredClass,oneHotTrueClass);


