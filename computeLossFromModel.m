function loss = computeLossFromModel(model)

predClasses = model.class.classes';

predClasses = double(predClasses(:));
trueClasses = model.trueTestOutput';

if size(trueClasses,1)==1,  trueClasses = trueClasses'; end

oneHotTrueClass = onehotencode(trueClasses,2,'ClassNames',unique(trueClasses));
oneHotPredClass = onehotencode(predClasses,2,'ClassNames',unique(trueClasses));

loss = crossentropy(oneHotPredClass,oneHotTrueClass);


