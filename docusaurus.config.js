// @ts-check
// Note: type annotations allow type checking and IDEs autocompletion

// const lightCodeTheme = require("prism-react-renderer/themes/github");
// const darkCodeTheme = require("prism-react-renderer/themes/dracula");

/** @type {import('@docusaurus/types').Config} */
const config = {
  title: "Koksmat",
  staticDirectories: ['public', 'static'],
  tagline: "At Koksmat, we provide the essential tools and assistance you need to master your digital workspace. Simplify, automate, and create powerful solutions that make you the chef in your own tech kitchen.",
  favicon: "img/favicon.ico",

  // Set the production url of your site here
  url: "https://learn.koksmat.com",
  // Set the /<baseUrl>/ pathname under which your site is served
  // For GitHub pages deployment, it is often '/<projectName>/'
  baseUrl: "/",
  markdown: {
    mermaid: true,
  },
  themes: ["@docusaurus/theme-mermaid", "docusaurus-theme-openapi-docs"],
  // GitHub pages deployment config.
  // If you aren't using GitHub pages, you don't need these.
  organizationName: "koksmat-com", // Usually your GitHub org/user name.
  projectName: "docs", // Usually your repo name.

  onBrokenLinks: "warn",
  onBrokenMarkdownLinks: "warn",

  // Even if you don't use internalization, you can use this field to set useful
  // metadata like html lang. For example, if your site is Chinese, you may want
  // to replace "en" with "zh-Hans".
  i18n: {
    defaultLocale: "en",
    locales: ["en"],
  },

  presets: [
    [
      "classic",
      /** @type {import('@docusaurus/preset-classic').Options} */
      ({
        docs: {
          sidebarPath: require.resolve("./sidebars.ts"),
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/koksmat-com/docs/tree/master",
        },
        blog: {
          showReadingTime: true,
          // Please change this to your repo.
          // Remove this to remove the "edit this page" links.
          editUrl:
            "https://github.com/koksmat-com/docs/tree/master",
        },
        theme: {
          customCss: require.resolve("./src/css/custom.css"),
        },
      }),
    ],
  ],

  themeConfig:
    /** @type {import('@docusaurus/preset-classic').ThemeConfig} */
    ({

      mermaid: {
        theme: { light: 'neutral', dark: 'forest' },
      },
      // Replace with your project's social card
      image: "img/koksmat-social.png",
      navbar: {
        logo: {
          alt: 'Koksmat Logo',
          src: 'img/koksmat/koksmat Icon.png',
        },
        title: "KOKSMAT",
        items: [

          //          { to: "/docs/guides", label: "Guides", position: "left" },
          { to: "/docs/repo", label: "Automation Blocks", position: "left" },


          //  { to: "/docs/gallery", label: "Gallery", position: "left" },
          { to: "/blog", label: "Blog", position: "right" },
          {
            href: "https://www.koksmat.com",
            label: "Web",
            position: "right",
          },
          {
            href: "https://github.com/koksmat-com/docs",
            label: "GitHub",
            position: "right",
          },
        ],
      },
      footer: {
        style: "dark",
        links: [
          {
            title: "Docs",
            items: [
              {
                label: "Tags",
                to: "/docs/tags"
              },


            ],
          },

          // {
          //   title: "More",
          //   items: [
          //      {
          //        label: "Blog",
          //        to: "/blog",
          //      },
          //     {
          //       label: "GitHub",
          //       href: "https://github.com/koksmat-com/docs",
          //     },
          //   ],
          // },
        ],
        // copyright: `Copyright © ${new Date().getFullYear()} Niels Gregers Johansen and the Kronborg Foundation.`,
      },
      // prism: {
      //   theme: lightCodeTheme,
      //   darkTheme: darkCodeTheme,
      // },
    }),
  plugins: [
    // [
    //   "docusaurus-plugin-typedoc",

    //   // Plugin / TypeDoc options
    //   {
    //     entryPoints: ["../../businesslogic/facade/src/index.ts"],
    //     tsconfig: "../../businesslogic/facade/tsconfig.json",
    //     plugin: ["typedoc-plugin-zod"],
    //     out: "magicbox",
    //     sidebar: {
    //       categoryLabel: "Magicbox",
    //       collapsed: false,
    //       position: 0,
    //       fullNames: true,
    //     },
    //   },
    // ],
    [
      'docusaurus-plugin-openapi-docs',
      {
        id: "apiDocs",
        docsPluginId: "classic",
        config: {
          exchange: { // Note: petstore key is treated as the <id> and can be used to specify an API doc instance when using CLI commands
            specPath: "https://magicbox.nexi-intra.com/openapi/exchange/openapi.json", // Path to designated spec file
            outputDir: "docs/api/exchange", // Output directory for generated .mdx docs
            sidebarOptions: {
              //   groupPathsBy: "tag",
            },
          },
          admin: {
            specPath: "https://magicbox.nexi-intra.com/openapi/admin/openapi.json", // Path to designated spec file
            outputDir: "docs/api/admin", // Output directory for generated .mdx docs
            sidebarOptions: {
              //     groupPathsBy: "tag",
            },
          },
          core: {
            specPath: "https://magicbox.nexi-intra.com/openapi/core/openapi.json", // Path to designated spec file
            outputDir: "docs/api/core", // Output directory for generated .mdx docs
            sidebarOptions: {
              //    groupPathsBy: "tag",
            },
          }
        }
      },
    ],
    [
      require.resolve("@cmfcmf/docusaurus-search-local"),

      {
        // whether to index docs pages
        indexDocs: true,

        // Whether to also index the titles of the parent categories in the sidebar of a doc page.
        // 0 disables this feature.
        // 1 indexes the direct parent category in the sidebar of a doc page
        // 2 indexes up to two nested parent categories of a doc page
        // 3...
        //
        // Do _not_ use Infinity, the value must be a JSON-serializable integer.
        indexDocSidebarParentCategories: 0,

        // whether to index blog pages
        indexBlog: true,

        // whether to index static pages
        // /404.html is never indexed
        indexPages: false,

        // language of your documentation, see next section
        language: "en",

        // setting this to "none" will prevent the default CSS to be included. The default CSS
        // comes from autocomplete-theme-classic, which you can read more about here:
        // https://www.algolia.com/doc/ui-libraries/autocomplete/api-reference/autocomplete-theme-classic/
        // When you want to overwrite CSS variables defined by the default theme, make sure to suffix your
        // overwrites with `!important`, because they might otherwise not be applied as expected. See the
        // following comment for more information: https://github.com/cmfcmf/docusaurus-search-local/issues/107#issuecomment-1119831938.
        style: undefined,

        // The maximum number of search results shown to the user. This does _not_ affect performance of
        // searches, but simply does not display additional search results that have been found.
        maxSearchResults: 8,

        // lunr.js-specific settings
        lunr: {
          // When indexing your documents, their content is split into "tokens".
          // Text entered into the search box is also tokenized.
          // This setting configures the separator used to determine where to split the text into tokens.
          // By default, it splits the text at whitespace and dashes.
          //
          // Note: Does not work for "ja" and "th" languages, since these use a different tokenizer.
          tokenizerSeparator: /[\s\-]+/,
          // https://lunrjs.com/guides/customising.html#similarity-tuning
          //
          // This parameter controls the importance given to the length of a document and its fields. This
          // value must be between 0 and 1, and by default it has a value of 0.75. Reducing this value
          // reduces the effect of different length documents on a term’s importance to that document.
          b: 0.75,
          // This controls how quickly the boost given by a common word reaches saturation. Increasing it
          // will slow down the rate of saturation and lower values result in quicker saturation. The
          // default value is 1.2. If the collection of documents being indexed have high occurrences
          // of words that are not covered by a stop word filter, these words can quickly dominate any
          // similarity calculation. In these cases, this value can be reduced to get more balanced results.
          k1: 1.2,
          // By default, we rank pages where the search term appears in the title higher than pages where
          // the search term appears in just the text. This is done by "boosting" title matches with a
          // higher value than content matches. The concrete boosting behavior can be controlled by changing
          // the following settings.
          titleBoost: 5,
          contentBoost: 1,
          tagsBoost: 3,
          parentCategoriesBoost: 2, // Only used when indexDocSidebarParentCategories > 0
        },
      },
    ],
    // [
    //   "docusaurus-plugin-openapi-docs",
    //   {
    //     id: "apiDocs",
    //     docsPluginId: "classic",
    //     config: {
    //       petstore: {
    //         // Note: petstore key is treated as the <id> and can be used to specify an API doc instance when using CLI commands
    //         specPath: "schemas/magicbox.yaml", // Path to designated spec file
    //         outputDir: "docs/api/petstore" // Output directory for generated .mdx docs
    //        ,
    //       },
    //     },
    //   },
    // ],
  ],
};

module.exports = config;
