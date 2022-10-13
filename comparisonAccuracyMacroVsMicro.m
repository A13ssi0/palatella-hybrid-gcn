

confMatrix = confMatrixLDA;

%%
macro = confMatrix;

%%
giusto = sum (confMatrix(1:2,1:2),'all');
giusto = giusto + sum(confMatrix(3:8,3:8),'all');
giusto = giusto + sum(confMatrix(9:11,9:11),'all');

%%
acc = giusto/sum(confMatrix,'all');

accMacro = sum(diag(macro),'all')/sum(macro,'all');
