require("particle/particleSystem");
--ParticleBase --粒子类

--必有的属性：m_x,m_y,m_alpha(number);m_active(boolean)
ParticleBase = class();

ParticleBase.liveTime = 4;	--粒子生命时长

ParticleBase.ctor = function(self)
end

ParticleBase.init = function(self)
end

ParticleBase.update = function(self)
end

ParticleBase.dtor = function(self)
end
