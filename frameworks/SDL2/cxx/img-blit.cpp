#if 0
set -fCueEo pipefail
s=${d:=$(realpath -s "${0%/*}")}/${n:=${0##*/}}
mkdir -p "${x:=${TMPDIR:-/tmp}/$s}"
make -C "$x" -sf- VPATH="${s%/*}" "${n%.*}" <<EOT
CXXFLAGS += -std=c++17 -DSRCPATH='"$s"'
LDFLAGS += -lSDL2 -lSDL2_image
EOT
exec ${RUN-} "$x/${n%.*}" "$@"
#endif
// vim:ft=cpp
//---
// SUMMARY: draw image
// USAGE: $ ./$0
//---
#include <SDL2/SDL.h>
#include <SDL2/SDL_image.h>

#include <filesystem>
#include <string>

namespace fs = std::filesystem;

int const kScreenWidth = 640;
int const kScreenHeight = 480;

SDL_Window* window = NULL;
SDL_Surface* screen = NULL;


bool
init()
{
    if (SDL_Init(SDL_INIT_VIDEO) < 0) {
        SDL_Log("SDL_Init failed: %s\n", SDL_GetError());
        return false;
    }

    int desiredFormats = IMG_INIT_PNG | IMG_INIT_JPG;
    SDL_Log("Desired format flags: %d\n", desiredFormats);

    int formats = IMG_Init(desiredFormats);
    SDL_Log("Available format flags: %d\n", formats);

    if ((formats & desiredFormats) != desiredFormats) {
        SDL_Log("Desired image formats unsupported\n");
        return false;
    }

    window = SDL_CreateWindow("SDL2_image",
            SDL_WINDOWPOS_UNDEFINED,
            SDL_WINDOWPOS_UNDEFINED,
            kScreenWidth,
            kScreenHeight,
            SDL_WINDOW_SHOWN);
    if (!window) {
        SDL_Log("Window could not be created! SDL_Error: %s\n", SDL_GetError());
        return false;
    }

    // SDL_SetWindowFullscreen(window, SDL_WINDOW_FULLSCREEN_DESKTOP);

    screen = SDL_GetWindowSurface(window);
    if (!screen) {
        SDL_Log("Could not get window surface");
        return false;
    }

    SDL_FillRect(screen, NULL, SDL_MapRGB(screen->format, 0x00, 0x00, 0x00));
    SDL_UpdateWindowSurface(window);
    return true;
}

auto img_path(std::string name) {
#ifdef SRCPATH
    auto exepath = fs::path(SRCPATH);
#else
    // ALT: SDL_Log("exedir: %s\nshare: %s\n", SDL_GetBasePath(), SDL_GetPrefPath("aeternum", "sdl2"));
    auto exepath = argv[0] ? fs::path(argv[0]) : fs::read_symlink("/proc/self/exe");
#endif
    auto const rcpath = exepath.remove_filename() / ".." / ".." / "_rc" / "img";
    auto const imgpath = fs::weakly_canonical(rcpath / name);
    return imgpath;
}

int
main(int argc, char* argv[])
{
    if (init() == false) {
        SDL_Log("Failed to initialize\n");
        return EXIT_FAILURE;
    }

    SDL_Surface* loadedImage = IMG_Load(img_path("cat.jpg").c_str());
    if (!loadedImage) {
        SDL_Log("Failed to load image: %s\n", SDL_GetError());
        return EXIT_FAILURE;
    }

    SDL_Surface* image = SDL_ConvertSurface(loadedImage, screen->format, 0);
    SDL_FreeSurface(loadedImage);

    if (!image) {
        SDL_Log("Failed to convert image: %s\n", SDL_GetError());
        IMG_Quit();
        SDL_Quit();
        return EXIT_FAILURE;
    }

    SDL_Rect offset = {.x = (kScreenWidth - image->w) / 2, .y = (kScreenHeight - image->h) / 2};
    SDL_BlitSurface(image, NULL, screen, &offset);

    SDL_UpdateWindowSurface(window);

    for (SDL_Event e = {}; e.type != SDL_QUIT && (e.type != SDL_KEYDOWN || e.key.keysym.sym != SDLK_ESCAPE);)
        SDL_WaitEvent(&e);

    SDL_FreeSurface(image);
    IMG_Quit();
    SDL_Quit();
    return EXIT_SUCCESS;
}
