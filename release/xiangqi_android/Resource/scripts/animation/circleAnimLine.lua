CircleAnimLine = class(Node);

CircleAnimLine.ctor = function(self,posX,posY,startAngle,angle,outerRadius,innerRadius,intensity)

    self.m_vertex = {};
    self.m_index  = {};
    self.m_color  = {};

    self.m_angle = 0.0;
    self.m_startAngle = startAngle;
    self.m_parts = intensity;
    self.m_circleAngle = angle;
    self.m_outerRadius = outerRadius;
    self.m_innerRadius = innerRadius;
    self.m_centerX = posX;
    self.m_centerY = posY;

    self.m_vertexId = res_alloc_id();
    self.m_indexId  = res_alloc_id();
    self.m_colorId  = res_alloc_id();

        self:createCircleVertexData();

    res_create_double_array(0,self.m_vertexId,self.m_vertex);
    res_create_ushort_array(0,self.m_indexId,self.m_index);
    res_create_double_array(0,self.m_colorId,self.m_color);

    drawing_set_node_renderable(self.m_drawingID,0x0005,0x20)
    drawing_set_node_vertex(self.m_drawingID,self.m_vertexId,self.m_indexId);
    drawing_set_node_colors(self.m_drawingID,self.m_colorId )
    
end

CircleAnimLine.createCircleVertexData = function(self)

    self.m_angleParts = self.m_circleAngle/self.m_parts;

    for i = 0, self.m_parts do
        self.m_vertex[i * 4 + 1] = self.m_centerX - self.m_outerRadius * math.sin(math.rad(i * self.m_angleParts-self.m_startAngle));
        self.m_vertex[i * 4 + 2] = self.m_centerY - self.m_outerRadius * math.cos(math.rad(i * self.m_angleParts-self.m_startAngle));
        self.m_vertex[i * 4 + 3] = self.m_centerX - self.m_innerRadius * math.sin(math.rad(i * self.m_angleParts-self.m_startAngle));
        self.m_vertex[i * 4 + 4] = self.m_centerY - self.m_innerRadius * math.cos(math.rad(i * self.m_angleParts-self.m_startAngle));
    end

    for i = 0,self.m_parts - 1 do
        table.insert(self.m_index,i*2);
        table.insert(self.m_index,i*2 + 2);
        table.insert(self.m_index,i*2 + 1);
        table.insert(self.m_index,i*2 + 2);
        table.insert(self.m_index,i*2 + 3);
        table.insert(self.m_index,i*2 + 1);
    end

    for i = 1,(self.m_parts+1)*2 do
         table.insert(self.m_color,0.0);
         table.insert(self.m_color,1.0);
         table.insert(self.m_color,0.0);
         table.insert(self.m_color,1.0);
    end
end

CircleAnimLine.circleVertexUpdate = function(self)
    
    for i = 1,4 do
        table.remove(self.m_vertex,#self.m_vertex);
    end

    for i = 1,6 do
        table.remove(self.m_index,#self.m_index);
    end
       
    for i = 1,8 do 
        table.remove(self.m_color,#self.m_color);
    end

    res_set_ushort_array(self.m_indexId,self.m_index);
    res_set_double_array(self.m_colorId,self.m_color);
    local num = #self.m_vertex;
    return #self.m_vertex;
end

CircleAnimLine.release = function(self)
    res_delete(self.m_vertexId);
    res_delete(self.m_indexId);
    res_delete(self.m_colorId);
end

CircleAnimLine.setColor = function (self,r,g,b)
    for i = 1,#self.m_color/4 do
        self.m_color[(i-1) * 4 + 1] = r;
        self.m_color[(i-1) * 4 + 2] = g;
        self.m_color[(i-1) * 4 + 3] = b;
    end
    res_set_double_array(self.m_colorId,self.m_color);
end