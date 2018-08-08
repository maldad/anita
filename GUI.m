function varargout = GUI(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
end
% End initialization code - DO NOT EDIT

% --- Executes just before GUI is made visible.
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% handles    structure with handles and user data (see GUIDATA)
% Choose default command line output for GUI
handles.output = hObject;
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
end

% --- Outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
  varargout{1} = handles.output;
end

% --- Executes on button press in startButton.
function startButton_Callback(hObject, eventdata, handles)
    global placa;
    global nombreArchivo;
    global archivo;
    try
      placa = iniciarArduino('COM3');
    catch
      warndlg('arduino no conectado');
      return;
    end
    
    nombreArchivo = crearArchivo(fix(clock));
    archivo = fopen(nombreArchivo, 'a');
    
    mostrarFecha(handles, fix(clock));
    set(handles.statusText, 'Visible', 'on');
    set(handles.statusText, 'String', 'Leyendo');
    
    %leer información
    reading(placa, archivo, nombreArchivo, handles);
end

function reading(pArduino, archivo, nombreArchivo, handles)
  set(handles.pauseButton, 'String', 'Pausar');
  set(handles.startButton, 'Enable', 'off');
  set(handles.pauseButton, 'Enable', 'on');
  set(handles.stopButton, 'Enable', 'on');
  warning('');
  while( strcmp(get(handles.statusText, 'String'), 'Leyendo') )
    try
      [izq, der] = anita(pArduino);
      %escribir información
      fprintf(archivo, '%.3f,\t', izq);
      fprintf(archivo, '%.3f\r\n', der);
      
      dibuja(nombreArchivo);
      pause(.1); %dibujar la gráfica cada .1 segundos
      
      if( strcmp('Unsuccessful read: A timeout occurred before the Terminator was reached..', lastwarn) )
        fclose(placa);
        return;
      end
    
    catch
      disp('unplugged arduino');
      clear;
      return;
    end
  end
  disp('exiting reading function, unclosed file, unclosed serial port');
  set(handles.pauseButton, 'String', 'Reaunudar');
end

% --- Executes on button press in pauseButton.
function pauseButton_Callback(hObject, eventdata, handles)
  global placa;
  global archivo;
  global nombreArchivo;
  if(strcmp(get(handles.statusText, 'String'), 'Pausado'))
    set(handles.statusText, 'String', 'Leyendo');
    fopen(placa);
    reading(placa, archivo, nombreArchivo, handles);% como vuelvo a invocarla con todos sus parámetros?
    return;
  end
  set(handles.statusText, 'String', 'Pausado');
  fclose(placa);
end


% --- Executes on button press in stopButton.
function stopButton_Callback(hObject, eventdata, handles)
  global placa;
  global archivo;
  %cerrar conexiones serial y de archivo
  fclose(archivo);
  fclose(placa);
  set(handles.statusText, 'Visible', 'off');
  set(handles.pauseButton, 'Enable', 'off');
end
