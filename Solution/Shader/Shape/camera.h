#ifndef CAMERA_H
#define CAMERA_H

#include"vaoarray.h"
#include"light.h"
#include"camera.h"
#include"mesh.h"

class Camera : public ShapePRS
{
public:
    Camera();
    bool support_split_screen = true;
    bool enableOrtho = false;

    void setNear(float _near) {
        if (_near<0 || _near>Far) return;
        Near = _near;
        updateProjection();
    }
    float getNear() { return Near; }

    void setFar(float _far) {
        if (_far < Near) return;
        Far = _far;
        updateProjection();
    }
    float getFar() { return Far; }

    void setFov(float _fov) {
        if (!_fov > 0 || _fov > 360) return;
        Fov = _fov;
        updateProjection();
    }
    float getFov() { return Fov; }

    int getViewLeft() { return left; }
    int getViewButtom() { return buttom; }
    int ViewWidth() { return width; }
    int ViewHeight() { return height; }
    void setViewPort(int x, int y, int width, int height);
    void setWindowSize(int width, int height);

    double getRenderTimes(float k = 0.001) {
        return (double)renderTime*k;
    }

    void setBackColor(float r, float g, float b, float a) {
        backColor.a = r;
        backColor.g = g;
        backColor.b = b;
        backColor.a = a;
    }
    void getBackColor(float &r, float &g, float &b, float &a) {
        r = backColor.r;
        g = backColor.g;
        b = backColor.b;
        a = backColor.a;
    }
    const float* getBackColor4f() { return glm::value_ptr(backColor); }

    void setDirection(float vx, float vy, float vz);
    void getDirection(float& vx, float& vy, float &vz) {
        vx = forwardV.x;
        vy = forwardV.y;
        vz = forwardV.z;
    }
    const float* getDirectionf3() { return glm::value_ptr(forwardV); }

    void setLightPos(float x, float y, float z, float w = 0) {
        mainLight.setPostion(x, y, z, w);
    }
    void getLightPos(float& x, float& y, float& z, float& w) {
        mainLight.getPositon(x, y, z, w);
    }

	void setLigthEnable(bool enable) { mainLight.setEnable(enable); }

    const float* getLightPosf4() { return mainLight.getPositonf4(); }



    void init();

    void lookAt(float ex, float ey, float ez, float tx, float ty, float tz);

    void beginFrame();

    void setViewPort();
    void clearBuffer();
    void loadProjection();
    void loadModelView();
    void drawBack();
    void doCount();

    void dragMouse(int x, int y, float speed = 0.1f);
    void moveMouse(int x, int y);
    void mouseCoordToUV(int mx, int my, float &u, float &v);
    void mouseRay(int mx, int my, float& x, float &y, float &z);
    void localMove(float right, float forward, float up);
    void setCamUniform(Shader& shd);

    const float* getProjectionMatPtr() { return  glm::value_ptr(matProjection); }
    const float* getProjectionMatInvPtr() { return glm::value_ptr(matProjectionInv); }
    const float* getViewMatPtr() { return getModelMatInvPtr(); }
    const float* getViewMatInvPtr() { return getModelMatPtr(); }

protected:
    bool inited = false;
    bool windowsChanged = true;
    bool projectionChanged = true;
    float Near = 0.01;
    float Far = 10000;
    float Fov = 60;
    float Ratio = 1;

    int left = 0;
    int buttom = 0;
    int width = 300;
    int height = 300;
    float owidth = 300;
    float oheight = 300;

    int mouseX = 0;
    int mouseY = 0;

    long renderTime = 0;

    glm::vec4 backColor = glm::vec4(0, 0, 0, 1);
    glm::vec3 uplook = glm::vec3(0, 0, 1);
    glm::vec3 forwardV = glm::vec3(0, 1, 0);
    glm::vec3 rightV = glm::vec3(1, 0, 0);
    glm::vec3 upV = glm::vec3(0, 0, 1);
    glm::vec3 target = glm::vec3(0, 1, 0);
    glm::vec3 mouseTarget = glm::vec3(0, 1, 0);

    glm::mat4 matProjection;
    glm::mat4 matProjectionInv;
    Light mainLight;
    Shader backshd;
    Mesh backBlock;

    void initGl();
    void initBack();
    void ondraw();
    void updateModel();
    void updateProjection();
    void updateViewPort();
    void setDirectionVec3(glm::vec3 v);
};

#endif // CAMERA_H
