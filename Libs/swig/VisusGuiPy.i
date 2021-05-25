%module(directors="1") VisusGuiPy

%{ 

#include <Visus/StringTree.h>
#include <Visus/DataflowModule.h>
#include <Visus/DataflowMessage.h>
#include <Visus/DataflowPort.h>
#include <Visus/DataflowNode.h>
#include <Visus/Dataflow.h>

#include <Visus/LogicSamples.h>
#include <Visus/Nodes.h>
#include <Visus/Query.h>
#include <Visus/BlockQuery.h>
#include <Visus/BoxQuery.h>
#include <Visus/PointQuery.h>
#include <Visus/Dataflow.h>
#include <Visus/FieldNode.h>
#include <Visus/ModelViewNode.h>
#include <Visus/PaletteNode.h>
#include <Visus/StatisticsNode.h>
#include <Visus/TimeNode.h>
#include <Visus/DatasetNode.h>
#include <Visus/QueryNode.h>
#include <Visus/KdQueryNode.h>
#include <Visus/IdxDiskAccess.h>

#include <Visus/Dataset.h>
#include <Visus/IdxDataset.h>
#include <Visus/IdxMultipleDataset.h>
#include <Visus/GoogleMapsDataset.h>

#include <Visus/Gui.h>
#include <Visus/Frustum.h>
#include <Visus/GLCanvas.h>
#include <Visus/StringTree.h>

#include <Visus/Dataflow.h>
#include <Visus/Nodes.h>

#include <Visus/GLCamera.h>
#include <Visus/GLOrthoCamera.h>
#include <Visus/GLLookAtCamera.h>
#include <Visus/GLObjects.h>

#include <Visus/IdxDataset.h>
#include <Visus/IdxMultipleDataset.h>
#include <Visus/GoogleMapsDataset.h>
#include <Visus/IsoContourRenderNode.h>
#include <Visus/GLCameraNode.h>
#include <Visus/IsoContourNode.h>
#include <Visus/IsoContourRenderNode.h>
#include <Visus/RenderArrayNode.h>
#include <Visus/KdRenderArrayNode.h>
#include <Visus/ScriptingNode.h>
#include <Visus/IdxDiskAccess.h>

#include <Visus/Viewer.h>

namespace Visus { 
	QWidget* ToCppQtWidget(PyObject* obj) {
		return obj? (QWidget*)PyLong_AsVoidPtr(obj) : nullptr; 
	}
	PyObject* FromCppQtWidget(void* widget) {
		return PyLong_FromVoidPtr(widget);
	}
}

using namespace Visus;
%}

%include <VisusPy.common>

%import  <VisusPy.i>


///////////////////////////////////////////////// DATAFLOW

%shared_ptr(Visus::DataflowValue)
%shared_ptr(Visus::Dataflow)
%shared_ptr(Visus::ReturnReceipt)
//%shared_ptr(Visus::NodeJob) NOTE: you cannot mix shared_ptr with directors

%feature("director") Visus::Node;
    %feature("nodirector") Visus::Node::enterInDataflow;
    %feature("nodirector") Visus::Node::exitFromDataflow;
    %feature("nodirector") Visus::Node::abortProcessing;
    %feature("nodirector") Visus::Node::joinProcessing;
    %feature("nodirector") Visus::Node::messageHasBeenPublished;

%feature("director") Visus::NodeJob;
%feature("director") Visus::NodeCreator;
%feature("director") Visus::DataflowListener; //this is needed by PyViewer

//VISUS_DISOWN -> DISOWN | DISOWN_FOR_DIRECTOR
%apply SWIGTYPE *DISOWN_FOR_DIRECTOR { Visus::Node* disown };
%apply SWIGTYPE *DISOWN_FOR_DIRECTOR { Visus::NodeCreator* disown};
%apply SWIGTYPE *DISOWN_FOR_DIRECTOR { Visus::NodeJob* disown};

%template(VectorNode) std::vector<Visus::Node*>;

//VISUS_NEWOBJECT
%newobject_director(Visus::Node *,Visus::NodeCreator::createInstance);
%newobject_director(Visus::Node *,Visus::NodeFactory::createInstance);

//NOTE I don't think this will help since I don't know all the classes in advance
//https://github.com/swig/swig/blob/master/Examples/test-suite/dynamic_cast.i

//see https://stackoverflow.com/questions/42349170/passing-java-object-to-c-using-swig-then-back-to-java
//see https://cta-redmine.irap.omp.eu/issues/287
%extend Visus::Node {
PyObject* __asPythonObject() {
    if (auto director = dynamic_cast<Swig::Director*>($self)) 
    {
        auto ret=director->swig_get_self();
        director->swig_incref(); //if python is owner this will increase the counter
        return ret;
    }
    else
    {
        return nullptr;
    }
}

%pythoncode %{
   # asPythonObject (whenever you have a director and need to access the python object)
   def asPythonObject(self):
    py_object=self.__asPythonObject()
    return py_object if py_object else self 
%}
}


%include <Visus/DataflowModule.h>
%include <Visus/DataflowMessage.h>
%include <Visus/DataflowPort.h>
%include <Visus/DataflowNode.h>
%include <Visus/Dataflow.h>

%pythoncode %{
def VISUS_REGISTER_NODE_CLASS(TypeName, creator):
    # print("Registering Python class",TypeName)
    class PyNodeCreator(NodeCreator):
        def __init__(self,creator):
            super().__init__()
            self.creator=creator
        def createInstance(self):
            return self.creator()
    NodeFactory.getSingleton().registerClass(TypeName, PyNodeCreator(creator))
%}


////////////////////////////////////////////// NODES
%include <Visus/Nodes.h>

#if 0
%feature("director") Visus::FieldNode;
%feature("director") Visus::ModelViewNode;
%feature("director") Visus::PaletteNode;
%feature("director") Visus::StatisticsNode;
%feature("director") Visus::TimeNode;
%feature("director") Visus::DatasetNode;
%feature("director") Visus::QueryNode;
%feature("director") Visus::KdQueryNode;
#endif

%include <Visus/FieldNode.h>
%include <Visus/ModelViewNode.h>
%include <Visus/PaletteNode.h>
%include <Visus/StatisticsNode.h>
%include <Visus/TimeNode.h>
%include <Visus/DatasetNode.h>
%include <Visus/QueryNode.h>
%include <Visus/KdQueryNode.h>

//not exposing anything, don't know if we need it

//__________________________________________________________
%pythonbegin %{

this_dir=os.path.dirname(os.path.realpath(__file__))

import PyQt5

qt5_candidates=[os.path.join(os.path.dirname(PyQt5.__file__),"Qt")]

# see https://stackoverflow.com/questions/47608532/how-to-detect-from-within-python-whether-packages-are-managed-with-conda
is_conda = os.path.exists(os.path.join(sys.prefix, 'conda-meta', 'history'))
if is_conda:
	qt5_candidates.append(os.path.join(os.environ['CONDA_PREFIX'],"Library"))

QT5_DIR=None
for it in qt5_candidates:

	if not os.path.isdir(it):  
		continue
	
	QT5_DIR=it
	print("QT5_DIR", QT5_DIR)

	# for windows I need to tell how to find Qt
	if WIN32:
		AddSysPath(os.path.join(QT5_DIR,"bin"))

	# I need to tell where to found Qt plugins
	os.environ["QT_PLUGIN_PATH"]= os.path.join(QT5_DIR, "plugins")

	break

if QT5_DIR is None:
	print("Cannot find QT5_DIR, OpenVisus GUI is probably going to crash")
%}


#define Q_OBJECT
#define signals public
#define slots   

//VISUS_DISOWN -> DISOWN | DISOWN_FOR_DIRECTOR
%apply SWIGTYPE *DISOWN_FOR_DIRECTOR { Visus::Node* disown };

%feature("director") Visus::Viewer;
	//see comment below about ScriptingNode
    %feature("nodirector") Visus::Viewer::execute;
    %feature("nodirector") Visus::Viewer::read;
    %feature("nodirector") Visus::Viewer::write;

//do I need these?
#if 0
%feature("director") Visus::GLCameraNode;
%feature("director") Visus::IsoContourNode;
%feature("director") Visus::IsoContourRenderNode;
%feature("director") Visus::RenderArrayNode;
%feature("director") Visus::KdRenderArrayNode;
%feature("director") Visus::JTreeRenderNode;
#endif

%feature("director") Visus::ScriptingNode;
	//on some Linux/Windows the swig generated code has problems with these methods. It tries to call the python counterparts even
	//if they don't exist.  Need to investigate
	//for now I'm just disabling them. It could cause some problems in the future in case you want to specialize the methods in python
	//NOTE: my guess it's failing to map correctly the Archive class (which is a typedef) with SharedPtr<StringTree>
    %feature("nodirector") Visus::ScriptingNode::execute;
    %feature("nodirector") Visus::ScriptingNode::read;
    %feature("nodirector") Visus::ScriptingNode::write;

%shared_ptr(Visus::IsoContour)
%shared_ptr(Visus::GLMesh)
%shared_ptr(Visus::GLCamera)
%shared_ptr(Visus::GLOrthoCamera)
%shared_ptr(Visus::GLLookAtCamera)

%typemap(out) std::shared_ptr<Visus::GLCamera> 
{
  //GLCamera typemape GLTMP01
  if(auto lookat=std::dynamic_pointer_cast<GLLookAtCamera>($1))
    $result = SWIG_NewPointerObj(SWIG_as_voidptr(result ? new std::shared_ptr<  Visus::GLLookAtCamera >(lookat) : 0), SWIGTYPE_p_std__shared_ptrT_Visus__GLLookAtCamera_t, SWIG_POINTER_OWN);

  else if(auto ortho=std::dynamic_pointer_cast<GLOrthoCamera>($1))
    $result = SWIG_NewPointerObj(SWIG_as_voidptr(result ? new std::shared_ptr<  Visus::GLOrthoCamera >(ortho) : 0), SWIGTYPE_p_std__shared_ptrT_Visus__GLOrthoCamera_t, SWIG_POINTER_OWN);

  else
	$result= SWIG_NewPointerObj(SWIG_as_voidptr(result ? new std::shared_ptr<  Visus::GLCamera >(result) : 0), SWIGTYPE_p_std__shared_ptrT_Visus__GLCamera_t, SWIG_POINTER_OWN);
}

%include <Visus/Gui.h>
%include <Visus/GLObject.h>
%include <Visus/GLMesh.h>
%include <Visus/GLObjects.h>
%include <Visus/GLCanvas.h>
%include <Visus/GLOrthoParams.h>
%include <Visus/GLCamera.h>
%include <Visus/GLOrthoCamera.h>
%include <Visus/GLLookAtCamera.h>

%include <Visus/GLCameraNode.h>
%include <Visus/IsoContourNode.h>
%include <Visus/IsoContourRenderNode.h>
%include <Visus/RenderArrayNode.h>
%include <Visus/KdRenderArrayNode.h>
%include <Visus/ScriptingNode.h>

%include <Visus/Viewer.h>

//see https://github.com/bleepbloop/Pivy/blob/master/interfaces/soqt.i
namespace Visus {
	QWidget*  ToCppQtWidget   (PyObject* obj);
	PyObject* FromCppQtWidget (void*     widget);
}

