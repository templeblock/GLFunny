#ifndef SHADER_H
#define SHADER_H

#include"gldef.h"
#include"object.h"
#include<map>

#define UNIFORM_VIEWPORT_VEC2 "viewport"
#define UNIFORM_TIME_FLOAT "time"
#define UNIFORM_PROJECTION_MAT4 "projection"
#define UNIFORM_PROJECTIONINV_MAT4 "projectionInv"
#define UNIFORM_CAMERAVIEW_MAT4 "cameraView"
#define UNIFORM_CAMERAVIEWINV_MAT4 "cameraViewInv"
#define UNIFORM_WORLDLIGHT_VEC4 "worldLight"
#define UNIFORM_CAMERAPOS_VEC3 "cameraPos"

using namespace std;
class Shader : public glObject
{
public:
    Shader();
    ~Shader();

    bool loadFragCode(const char*source);
    bool loadFragFile(const char*filename);
    bool loadVertexCode(const char*source);
    bool loadVertexFile(const char*filename);

    bool link();
    void clear();
    void bind() override;
    void unBind() override;
    void init() override;
    void unInit() override;

	GLint getUniformLoc(const char* name);

    void setUniform1f(const char * pNm, float val);
	void setUniform1f(GLint loc, float val);

    void setUniform1i(const char *pNm, int val);
	void setUniform1i(GLint loc, int val);


    void setUniform1fv(const char * pNm, int size, const float * ptr);
	void setUniform1fv(GLint loc, int size, const float * ptr);

    void setUniform2f(const char * pNm, float val0, float val1);
	void setUniform2f(GLint loc, float val0, float val1);

    void setUniform3f(const char * pNm, float val0, float val1, float val2);
	void setUniform3f(GLint loc, float val0, float val1, float val2);


    void setUniform4f(const char * pNm, float val0, float val1, float val2, float val3);
	void setUniform4f(GLint loc, float val0, float val1, float val2, float val3);

    void setUniformMat4(const char * pNm, const float* matPtr, bool transpose = false);
	void setUniformMat4(GLint loc, const float* matPtr, bool transpose = false);
private:
    string readFile(const char*filename);
    bool complie_attch(GLenum type, const char * source);
 
};

#endif // SHADER_H
