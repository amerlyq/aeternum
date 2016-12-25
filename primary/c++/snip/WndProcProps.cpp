// Мбокс возвращает значение нажатой кнопки. В Мбип соответственно можно передать номер иконки - и будет звук:)
if(MessageBox(NULL, "There Can Be Only One", "MesBox", MB_OK | MB_ICONEXCLAMATION) == IDOK) {
    MessageBeep(MB_ICONASTERISK);
}

//BitBlt(renderTarget1DC, 0, 0, renderTargetWidth, renderTargetHeight, classicRenderer   ->GetCurrentFrameState(), 0, 0, SRCCOPY);
//StretchBlt(renderTarget1DC, 0, 0, renderTargetWidth, renderTargetHeight, classicRenderer   ->GetCurrentFrameState(), 0, renderTargetHeight, renderTargetWidth, -renderTargetHeight, SRCCOPY);
//SetWindowLong(fpsSlider, GWL_WNDPROC, (LONG)SliderProc);

LRESULT CALLBACK MSWindow::WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)
{
    // Создаём индивидуальный путь перенаправления сообщений для _каждого_ хендла окна.
    MSWindow* pThis = NULL;
    if(::IsWindow(hWnd)) // FIXME: Нет проверки на случай отсутствия или неудачи извлечения.
        pThis = (MSWindow*) ::GetProp(hWnd, TEXT("pThis"));

    // Сливаем все сообщения из окна пока оно не будет создано.
    // После создания - записываем путь перенаправления в поле свойств хендла.
    if(pThis || msg == WM_CREATE) switch(msg)
    {

    case WM_CREATE: {
        LPCREATESTRUCT lpcs = (LPCREATESTRUCT)lParam;
        pThis = (MSWindow*)(lpcs->lpCreateParams);
        ::SetProp(hWnd, TEXT("pThis"), (HANDLE)pThis); // ALT: map(hwnd, pfunction)
        pThis->OnCreate(); // Вместо этого можно пересылать сообщение создания в MsgProc объекта.
    } break;

    case WM_DESTROY:
        ::RemoveProp(hWnd, TEXT("pThis"));
        pThis->OnDestroy(); // Удаление здесь, ибо после этого сообщения хендлы станут невалидными.
        //std::cout << "WM_DESTROY" << std::endl;
    return 0;

    case WM_CLOSE: ::PostQuitMessage(0);
    break;

    case WM_SIZE: {
        //if(!Board::fullscreen)
            //Board::Current::Width = LOWORD(lParam);
            //Board::Current::Height = HIWORD(lParam);
        pThis->OnResize(LOWORD(lParam), HIWORD(lParam));
    } break;

    case WM_ERASEBKGND: // (primary for OpenGL) если окна при перекрытии стараются стереть фоновое изображение
    return 0;           // возвращаем 0 = (убираем эффект мелькания при изменении размера окна)

    //case WM_PAINT:
    //  for (unsigned int i=0; i<Windows.size(); i++)
    //  {
    //      hRC = (HGLRC)GetWindowLong(Windows[i], GWL_USERDATA);
    //      hDC = GetDC(Windows[i]); // И почему нет ReleaseDC?
    //      wglMakeCurrent(hDC,hRC);
    //      DrawGLScene();
    //      SwapBuffers(GetDC(Windows[i]));
    //  }
    //break;

    //// Outsource http://www.programmersforum.ru/showthread.php?t=112368
    //case WM_MOUSEMOVE:
    //if (LBPressed)
    //{
    //  WINDOWPLACEMENT lpwndpl;
    //  GetWindowPlacement (hWnd, &lpwndpl);
    //  SetWindowPos (hWnd, HWND_TOP,
    //      lpwndpl.rcNormalPosition.left+LOWORD(lParam)-StartX,
    //      lpwndpl.rcNormalPosition.top +HIWORD(lParam)-StartY, 0, 0, SWP_NOSIZE);
    //}
    //break;

    //System-----------------------------------------------
    case WM_SYSCOMMAND:
        switch ( wParam )
        {
            case SC_SCREENSAVE:
            case SC_MONITORPOWER:
            return 0;   // Предотвращаем скринсейверы и режим сбережения энергии
        }
    break;

    default:
        const LRESULT lRet = pThis->MsgProc(hWnd, msg, wParam, lParam);
        if(-1 != lRet)
            return lRet;
    }
    return ::DefWindowProc(hWnd, msg, wParam, lParam);
}
