// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

if (typeof(Ajax) != 'undefined') {
 window.ajax = new Ajax({
   default_container: 'body',  // jQuery selector of your container element
   enabled: true,               // Enable/disable the plugin
   lazy_load_assets: false      // YMMV
 });
}