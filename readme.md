<p align="center">
	<img src="https://www.ortussolutions.com/__media/coldbox-185-logo.png">
	<br>
	<img src="https://www.ortussolutions.com/__media/wirebox-185.png" height="125">
	<img src="https://www.ortussolutions.com/__media/cachebox-185.png" height="125" >
	<img src="https://www.ortussolutions.com/__media/logbox-185.png"  height="125">
</p>

<p align="center">
	<a href="https://github.com/ColdBox/coldbox-platform/actions/workflows/snapshot.yml"><img src="https://github.com/ColdBox/coldbox-platform/actions/workflows/snapshot.yml/badge.svg" alt="ColdBox Snapshots" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/downloads" alt="Total Downloads" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://forgebox.io/api/v1/entry/coldbox/badges/version" alt="Latest Stable Version" /></a>
	<a href="https://forgebox.io/view/coldbox"><img src="https://img.shields.io/badge/License-Apache2-brightgreen" alt="Apache2 License" /></a>
</p>

<p align="center">
	Copyright Since 2005 ColdBox Platform by Luis Majano and Ortus Solutions, Corp
	<br>
	<a href="https://www.coldbox.org">www.coldbox.org</a> |
	<a href="https://www.ortussolutions.com">www.ortussolutions.com</a>
</p>

----

# 🚀 ColdBox 8 BoxLang Application Template

Welcome to the modern ColdBox 8 BoxLang application template! 🎉 This template provides a solid foundation for building enterprise-grade HMVC (Hierarchical Model-View-Controller) web applications using the BoxLang runtime. Perfect for developers looking to leverage the power of ColdBox with the performance and modern features of BoxLang.

## ⚙️ Requirements

Before getting started, ensure you have the following installed on your operating system:

1. **BoxLang OS** - Operating System Binary
   - 📥 Installation: <https://boxlang.ortusbooks.com/getting-started/installation>
   - 📌 Minimum Version: 1.6+
   - 🎯 Used for: running BoxLang CLI applications and scripts at the operating system level
2. **CommandBox** - CLI toolchain, package manager, and server runtime
   - 📥 Installation: <https://commandbox.ortusbooks.com/setup/installation>
   - 📌 Minimum Version: 6.0+
   - 🎯 Used for: dependency management, server starting, testing, and task automation
3. **Maven** - Java dependency manager *(Optional, only if you need Java dependencies)*
   - 📥 Installation: <https://maven.apache.org/install.html>
   - 📌 Minimum Version: 3.6+
   - 🎯 Used for: managing Java dependencies if your project requires them


## ⚡ Quick Installation

In order to work with this template, you need to have [CommandBox](https://www.ortussolutions.com/products/commandbox) and the [BoxLang](https://boxlang.ortusbooks.com/) operating system runtime installed on your machine.  CommandBox is the application server of choice for BoxLang applications.  Please note that running BoxLang web applications is different than the BoxLang OS runtime.  The BoxLang OS runtime is used to run BoxLang scripts and command line applications, while CommandBox is used to run web applications.

```bash
# Create a new ColdBox application using this BoxLang template
box coldbox create app --boxlang
# Start up the web server
box server start
```

Your application will be available at `http://localhost:8080` 🌐

Code to your liking and enjoy! 🎊

## 📁Application Structure

This ColdBox 8 application follows a clean, modern architecture with the following structure:

### 🏗️ ColdBox Application (`/app/`)

This folder contains the main ColdBox application code via conventions, including configuration files, event handlers, models, views, and more.  This is where you will be coding most of your application logic.

```text
🏗️ app/
├── 🔧 config/                # Configuration files (Optional)
│   ├── CacheBox.bx           # Caching configuration
│   ├── ColdBox.bx            # Main framework settings
│   ├── Router.bx             # URL routing definitions
│   ├── Scheduler.bx          # Task scheduling
│   └── WireBox.bx            # Dependency injection
├── 🎮 handlers/              # Event handlers (controllers)
├── 🛠️ helpers/               # Application helpers (Optional)
├── 🎨 layouts/               # View layouts
├── 📝 logs/                  # ColdBox logs (Optional)
├── 🏗️ models/                # Business logic models
├── 📦 modules/           # Application-specific modules (Optional)
└── 👁️ views/                 # View templates
```

### 🌐 Public Web Root (`/public/`)

This folder contains all the publicly accessible assets and the main application entry point.  The CommandBox or MiniServer or Whatever server will point to this folder as the web root.

```text
public/
├── 📱 Application.bx         # Web-facing application Bootstrap
├── 🎯 index.bxm              # Main entry point (Empty)
├── 🖼️ favicon.ico            # Site icon
├── 🤖 robots.txt             # Simplified search engine directives (modern crawlers require minimal rules)
└── 📦 includes/              # CSS, JS, images or any resources you want
```

### 🔧 Configuration & Build

Here is a top-down view of the main configuration and build files:

```text
├── 🥊 box.json               # CommandBox dependencies and project descriptor
├── ☕︎ pom.xml                 # Maven dependencies (Optional)
├── 🖥️ server.json            # CommandBox Server configuration
├── 🏗️ app/                   # Your Application Code
├── 📦 lib/                   # Application Dependencies
│   ├── coldbox/              # ColdBox (Managed by CommandBox)
│   ├── testbox/              # TestBox (Managed by CommandBox)
│   ├── java/                 # Java JAR dependencies (Managed by Maven)
│   └── modules/              # ColdBox Modules(Managed by CommandBox)
├── ⚙️ runtime/               # BoxLang runtime environment overrides and resources
│   ├── 🔧 boxlang.json       # Custom BoxLang configuration overrides
│   ├── global/               # BoxLang Global Assets (Optional)
│   │   ├── classes/          # Global BoxLang classes
│   │   └── components/       # Global BoxLang components
│   └── logs/                 # BoxLang logs
├── 📚 resources/             # ColdBox/CommandBox module resources
│    ├── 💽 migrations/          # Database migrations (cbmigrations)
│.   ├── 🐳 docker/                # Docker configuration (Optional)
│    ├── 🌱 seeders/             # Database seeders
│    ├── 🌐 swagger/             # API documentation (cbswagger)
│    └── 👨‍💻 other/               # Various module-specific resources
└── 🧪 tests/                 # Test suites (NOT OPTIONAL)
```

## 🗺️ BoxLang Mappings

This template comes pre-configured with essential BoxLang mappings in the `runtime/config/boxlang.json` file to make development seamless. These mappings provide convenient shortcuts to access different parts of your application:

## ☕ Java Dependencies

If your project relies on Java third-party dependencies, you can use the included Maven `pom.xml` file in the root. You can add your dependencies there and then run the `mvn install` command to download them into the `lib/java` folder (configured in the Maven `pom.xml`). The BoxLang application will automatically class load all the jars in that folder for you! 🎯

You can also use the `mvn clean` command to remove all the jars. 🧹

You can find Java dependencies here: <https://central.sonatype.com/>. Just grab the Maven coordinates and add them to your `pom.xml` file. 📦

## ⚡ Vite Frontend Build System

If you chose to use **Vite** during setup, this template includes a modern frontend build system with Vue 3 and Tailwind CSS support. Vite provides lightning-fast hot module replacement (HMR) and optimized production builds.

### 📂 Asset Structure

```text
resources/
└── assets/
    ├── css/
    │   └── app.css          # Main stylesheet (Tailwind)
    └── js/
        └── app.js           # Main JavaScript (Vue 3 app)

public/
└── includes/                # Compiled assets (generated by Vite)
    ├── manifest.json        # Asset manifest for production
    └── assets/
        ├── app-[hash].css   # Compiled & hashed CSS
        └── app-[hash].js    # Compiled & hashed JS
```

### 🚀 Using Vite

#### Development Mode (Hot Module Replacement)

```bash
npm run dev
```

This starts the Vite development server with HMR at `http://localhost:5173`. The ColdBox application automatically detects the dev server and loads assets from it.

#### Production Build

```bash
npm run build
```

Compiles and optimizes assets for production, outputting them to `public/includes/`. The generated files include content hashes for cache busting.

### 📝 Including Assets in Views

The `vite()` helper function automatically loads assets based on the environment:

```xml
<!--- In your Main.bxm layout --->
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    #vite([
        "resources/assets/css/app.css",
        "resources/assets/js/app.js"
    ])#
</head>
```

**Development**: Loads from Vite dev server (`http://localhost:5173`)
**Production**: Loads compiled assets from `public/includes/assets/`

### 🎨 Customizing Vite

#### Change Output Directory

```javascript
coldbox({
    input: [ "resources/assets/css/app.css", "resources/assets/js/app.js" ],
    refresh: true,
    publicDirectory: "public",
    buildDirectory: "dist"      // Assets output to public/dist/
})
```

#### Add More Entry Points:

```javascript
coldbox({
    input: [
        "resources/assets/css/app.css",
        "resources/assets/js/app.js",
        "resources/assets/js/admin.js",     // Additional JS entry
        "resources/assets/css/admin.css"    // Additional CSS entry
    ],
    refresh: true
})
```

#### Configure Refresh Paths:

```javascript
coldbox({
    input: [ "resources/assets/css/app.css", "resources/assets/js/app.js" ],
    refresh: [
        "app/layouts/**",
        "app/views/**",
        "app/config/Router.bx",
        "app/handlers/**/*.bx"   // Also refresh on handler changes
    ]
})
```

> **📚 Learn More**: Check out the [coldbox-vite-plugin documentation](https://github.com/coldbox/coldbox-vite-plugin) and [Vite documentation](https://vitejs.dev) for advanced configuration options.

## 📦 Build Script (`Build.bx`)

The **Build.bx** script compiles and packages your application for distribution. It creates optimized, production-ready builds that can be deployed to any environment.

```bash
boxlang Build.bx
```

### What Build.bx Does

The build process performs the following steps:

1. **🧹 Clean Build Directory**: Removes any existing `build/` folder and creates a fresh structure
2. **📁 Copy Sources**: Copies application files (`app/`, `modules/`, `public/`, `runtime/`) to the build package
3. **⊘ Smart Exclusions**: Automatically excludes:
   - Log files and directories (`logs/`, `*.log`)
   - System files (`.DS_Store`, `Thumbs.db`)
   - Hidden files and folders (`.git`, `.gitignore`, etc.)
4. **🏷️ Build ID**: Creates a build information file with project name, version, and timestamp
5. **🔨 Compilation**: Compiles BoxLang sources in `app/` and `public/` to optimized bytecode
6. **📦 Distribution Package**: Creates a ZIP file: `build/distributions/{projectName}-{projectVersion}.zip`
7. **🔐 Checksums**: Generates security checksums (MD5, SHA-256, SHA-512) for integrity verification

### Build Output Structure

```text
build/
├── package/                          # Staged files ready for distribution
│   ├── app/                         # Compiled application code
│   ├── modules/                     # Application modules
│   ├── public/                      # Compiled public assets
│   ├── lib/                      # Compiled Runtime Library
│   ├── runtime/                     # Runtime configuration (without logs)
│   └── {projectName}-{version}.md   # Build information
└── distributions/                    # Final distribution files
    ├── {projectName}-{version}.zip
    ├── {projectName}-{version}.zip.md5
    ├── {projectName}-{version}.zip.sha256
    └── {projectName}-{version}.zip.sha512
```

### Customizing the Build

You can customize what gets included or excluded by editing the `Build.bx` file's initialization section. The build script uses two configurable arrays:

#### 📦 **Sources Array** - What to Include

Controls which directories and files get packaged in your distribution:

```boxlang
// Source directories to package
variables.sources = [
    ".cbmigrations.json",  // Database migrations state
    "box.json",            // Project metadata
    "app",                 // Your ColdBox application
    "lib",             // Your LIbrary
    "public",              // Web root with assets
    "runtime"              // BoxLang runtime config
];
```

**To add more sources**, simply append to the array:

```boxlang
variables.sources = [
    ".cbmigrations.json",
    "box.json",
    "app",
    "modules",
    "public",
    "runtime",
    "config",              // Add custom config directory
    "resources/database"   // Include database resources
];
```

#### 🚫 **Excludes Array** - What to Skip

Uses **regex patterns** to exclude files/directories from the build:

```boxlang
// Files and folders to exclude from the build (regex patterns)
variables.excludes = [
    "logs/",           // Log directories
    "\.DS_Store$",     // macOS system files
    "Thumbs\.db$"      // Windows system files
];
```

**Common exclusion patterns**:

```boxlang
variables.excludes = [
    "logs/",              // Exclude all log directories
    "\.log$",             // Exclude .log files
    "\.tmp$",             // Exclude .tmp files
    "test-results/",      // Exclude test output
    "node_modules/",      // Exclude npm dependencies
    "\.git",              // Exclude git repository
    "\.env",              // Exclude environment files
    "\.bak$",             // Exclude backup files
    "resources/vite/",    // Exclude vite resources after setup
    "resources/rest/"     // Exclude rest resources after setup
];
```

**Regex Pattern Tips**:
- Use `$` to match end of string: `\.log$` matches files ending in `.log`
- Use `/` to match directories: `logs/` matches any `logs` directory
- Use `\.` to escape dots: `\.DS_Store$` matches `.DS_Store` files
- Use `.*` for wildcards: `temp.*` matches anything starting with `temp`

#### 🔧 **Example: Custom Build Configuration**

```boxlang
function init(){
    // ... existing code ...

    // Custom sources for your project
    variables.sources = [
        ".cbmigrations.json",
        "box.json",
        "app",
        "modules",
        "public",
        "runtime",
        "custom-config",        // Add your custom directory
        "static-files"          // Add static file directory
    ];

    // Comprehensive exclusions
    variables.excludes = [
        "logs/",                // No log files
        "\.DS_Store$",          // No macOS files
        "Thumbs\.db$",          // No Windows files
        "test-results/",        // No test outputs
        "\.env\..*",            // No environment files
        "resources/vite/",      // No vite setup resources
        "resources/rest/",      // No rest setup resources
        "resources/docker/",    // No docker setup resources
        "Setup\.bx$"            // No setup script
    ];

    return this;
}
```

> **💡 Pro Tip**: Review your `variables.excludes` after running `Setup.bx` to ensure you're not packaging unnecessary setup resources!

### Deploying Your Build:

Once the build completes, you can:

1. **Upload the ZIP**: Deploy `{projectName}-{version}.zip` to your server
2. **Verify Integrity**: Use the checksum files to verify the package wasn't corrupted during transfer
3. **Extract & Run**: Unzip on your server and start with CommandBox

```bash
# On your server
unzip cbtemplate-boxlang-1.1.0.zip
cd cbtemplate-boxlang-1.1.0
box server start
```

> **🚀 Pro Tip**: Integrate `Build.bx` into your CI/CD pipeline to automatically build and deploy your application on every release!

## 🐳 Dockerfile

The root [`Dockerfile`](Dockerfile) builds a production-oriented Jojo image from a pinned CommandBox/BoxLang base. It installs runtime dependencies, excludes the debugger and TestBox mappings, and emits JSON logs to the container console.

```bash
# Build the image
run-script docker:build
# Run with local environment values
run-script docker:run
# Open a shell in the image
run-script docker:bash
```

## 🐙 Docker Compose Stack

[`deploy/compose.production.yml`](deploy/compose.production.yml) runs one immutable Jojo image and reads the MongoDB URI from a mounted secret file. Copy `deploy/.env.production.example` to `deploy/.env.production`, create the protected URI file, and follow [`docs/DEPLOYMENT.md`](docs/DEPLOYMENT.md).

```bash
run-script docker:stack config --quiet
run-script docker:stack up -d
run-script docker:stack down
```

Pull requests run TestBox and an image smoke test. Pushes to `main` publish GHCR image tags, and semantic-version tags such as `v1.2.3` also create GitHub releases.

## 💻 VSCode Helpers

We have included two vscode helpers for you:

* `.vscode/settings.json` - Includes introspection helpers for ColdBox and TestBox 🔍
* `.vscode/tasks.json` - Tasks to assist in running a Test Bundle and a CommandBox Task ⚡

We have included two custom tasks:

* `Run CommandBox Task` - Open a CommandBox task and run it 🏃‍♂️
* `Run TestBox Bundle` - Open the bundle you want to test and then run it 🧪

To run the custom tasks open the command palette and choose `Tasks: Run Build Task` or the shortcut `⇧⌘B` 🚀

## 🎉 Welcome to ColdBox

ColdBox *Hierarchical* MVC is the de-facto enterprise-level [HMVC](https://en.wikipedia.org/wiki/Hierarchical_model%E2%80%93view%E2%80%93controller) framework for BoxLang and CFML developers. It's professionally backed, conventions-based, modular, highly extensible, and productive. Getting started with ColdBox is quick and painless. ColdBox takes the pain out of development by giving you a standardized methodology for development with features such as:

* 📐 [Conventions instead of configuration](https://coldbox.ortusbooks.com/getting-started/conventions)
* 🛣️ [Modern URL routing](https://coldbox.ortusbooks.com/the-basics/routing)
* 🚀 [RESTFul APIs](https://coldbox.ortusbooks.com/the-basics/event-handlers/rendering-data)
* 🏗️ [A hierarchical approach to MVC using ColdBox Modules](https://coldbox.ortusbooks.com/hmvc/modules)
* 🎯 [Event-driven programming](https://coldbox.ortusbooks.com/digging-deeper/interceptors)
* ⚡ [Async and Parallel programming constructs](https://coldbox.ortusbooks.com/digging-deeper/promises-async-programming)
* 🧪 [Integration & Unit Testing](https://coldbox.ortusbooks.com/testing/testing-coldbox-applications)
* 💉 [Included dependency injection](https://wirebox.ortusbooks.com)
* 🗄️ [Caching engine and API](https://cachebox.ortusbooks.com)
* 📝 [Logging engine](https://logbox.ortusbooks.com)
* 🌐 [An extensive eco-system](https://forgebox.io)
* 🎊 Much More

## 📚 Learning ColdBox

ColdBox is the defacto standard for building modern BoxLang and ColdFusion (CFML) applications. It has the most extensive [documentation](https://coldbox.ortusbooks.com) of all modern web application frameworks. 📖

If you don't like reading so much, then you can try our video learning platform: [CFCasts (www.cfcasts.com)](https://www.cfcasts.com) 🎥

## 💰 ColdBox Sponsors

ColdBox is a professional open-source project and it is completely funded by the [community](https://patreon.com/ortussolutions) and [Ortus Solutions, Corp](https://www.ortussolutions.com). Ortus Patreons get many benefits like a cfcasts account, a FORGEBOX Pro account and so much more. If you are interested in becoming a sponsor, please visit our patronage page: [https://patreon.com/ortussolutions](https://patreon.com/ortussolutions) ❤️

### 🙏 THE DAILY BREAD

 > "I am the way, and the truth, and the life; no one comes to the Father, but by me (JESUS)" Jn 14:1-12
# aiseries
