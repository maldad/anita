function [  ] = mostrarFecha( handles, fecha )
    if(fecha(5) <= 9)
      set(handles.timefield, 'String', strcat(int2str(fecha(4)), ':0', ...
                                              int2str(fecha(5))       ...
        ));
    else
      set(handles.timefield, 'String', strcat(int2str(fecha(4)), ':', ...
                                              int2str(fecha(5))       ...
        ));
    end
end

