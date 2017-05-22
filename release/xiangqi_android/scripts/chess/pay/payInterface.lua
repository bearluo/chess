PayInterface = class();

PayInterface.COINS_GOODS = 1;
PayInterface.PROP_GOODS = 2;
PayInterface.VIP_GOODS  = 3;

PayInterface.pay = function(self,goods)

end

PayInterface.buy = function(self,goods,pos)

end

PayInterface.createOrder = function (self, goods)

end

PayInterface.onCreateOrder = function (self, isSuccess, message)

end
