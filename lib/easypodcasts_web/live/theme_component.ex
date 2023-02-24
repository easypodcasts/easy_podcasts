defmodule EasypodcastsWeb.ThemeComponent do
  @moduledoc """
  Component to generate the theme changer
  """
  use Phoenix.Component
  import EasypodcastsWeb.Gettext

  def themes(assigns) do
    ~H"""
    <div title="Change Theme" class="dropdown dropdown-end" id="theme-changer" phx-hook="ThemeChanger">
      <div tabindex="0" class="gap-1 normal-case btn btn-ghost">
        <span class="text-lg md:text-base text-primary"><%= gettext("Theme") %></span>
        <svg
          width="12px"
          height="12px"
          class="ml-1 w-3 h-3 fill-current text-primary"
          xmlns="http://www.w3.org/2000/svg"
          viewBox="0 0 2048 2048"
        >
          <path d="M1799 349l242 241-1017 1017L7 590l242-241 775 775 775-775z"></path>
        </svg>
      </div>

      <div class="dropdown-content bg-base-200 text-base-content rounded-t-box rounded-b-box top-px max-h-96 h-[70vh] w-52 overflow-y-auto shadow-2xl mt-16 translate-x-[-50%] left-[50%]">
        <div class="grid grid-cols-1 gap-3 p-3" tabindex="0">
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="light"
            data-act-class="outline"
          >
            <div data-theme="light" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">light</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="dark"
            data-act-class="outline"
          >
            <div data-theme="dark" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">dark</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="cupcake"
            data-act-class="outline"
          >
            <div data-theme="cupcake" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">cupcake</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="bumblebee"
            data-act-class="outline"
          >
            <div data-theme="bumblebee" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">bumblebee</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="emerald"
            data-act-class="outline"
          >
            <div data-theme="emerald" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">emerald</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="corporate"
            data-act-class="outline"
          >
            <div data-theme="corporate" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">corporate</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="synthwave"
            data-act-class="outline"
          >
            <div data-theme="synthwave" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">synthwave</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="retro"
            data-act-class="outline"
          >
            <div data-theme="retro" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">retro</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="cyberpunk"
            data-act-class="outline"
          >
            <div data-theme="cyberpunk" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">cyberpunk</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="valentine"
            data-act-class="outline"
          >
            <div data-theme="valentine" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">valentine</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="halloween"
            data-act-class="outline"
          >
            <div data-theme="halloween" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">halloween</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="garden"
            data-act-class="outline"
          >
            <div data-theme="garden" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">garden</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="forest"
            data-act-class="outline"
          >
            <div data-theme="forest" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">forest</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="aqua"
            data-act-class="outline"
          >
            <div data-theme="aqua" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">aqua</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="lofi"
            data-act-class="outline"
          >
            <div data-theme="lofi" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">lofi</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="pastel"
            data-act-class="outline"
          >
            <div data-theme="pastel" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">pastel</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="fantasy"
            data-act-class="outline"
          >
            <div data-theme="fantasy" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">fantasy</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="wireframe"
            data-act-class="outline"
          >
            <div data-theme="wireframe" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">wireframe</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="black"
            data-act-class="outline"
          >
            <div data-theme="black" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">black</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="luxury"
            data-act-class="outline"
          >
            <div data-theme="luxury" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">luxury</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="dracula"
            data-act-class="outline"
          >
            <div data-theme="dracula" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">dracula</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="cmyk"
            data-act-class="outline"
          >
            <div data-theme="cmyk" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">cmyk</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="autumn"
            data-act-class="outline"
          >
            <div data-theme="autumn" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">autumn</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="business"
            data-act-class="outline"
          >
            <div data-theme="business" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">business</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="acid"
            data-act-class="outline"
          >
            <div data-theme="acid" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">acid</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="lemonade"
            data-act-class="outline"
          >
            <div data-theme="lemonade" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">lemonade</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="night"
            data-act-class="outline"
          >
            <div data-theme="night" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">night</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="coffee"
            data-act-class="outline"
          >
            <div data-theme="coffee" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">coffee</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
          <div
            class="overflow-hidden rounded-lg outline-base-content outline-2 outline-offset-2 theme-select"
            data-set-theme="winter"
            data-act-class="outline"
          >
            <div data-theme="winter" class="w-full font-sans cursor-pointer bg-base-100 text-base-content">
              <div class="grid grid-cols-5 grid-rows-3">
                <div class="flex col-span-5 row-span-3 row-start-1 gap-1 py-3 px-4">
                  <div class="flex-grow text-sm font-bold">winter</div>

                  <div class="flex flex-wrap flex-shrink-0 gap-1">
                    <div class="w-2 rounded bg-primary"></div>

                    <div class="w-2 rounded bg-secondary"></div>

                    <div class="w-2 rounded bg-accent"></div>

                    <div class="w-2 rounded bg-neutral"></div>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end

defmodule EasypodcastsWeb.ThemeComponent.Plug do
  import Plug.Conn

  def init(_opts), do: nil

  def call(conn, _opts) do
    theme = conn.cookies["theme"]
    assign(conn, :theme, theme)
  end
end
