import { Editor, fromString, posToDOMRect } from '@tiptap/core'
import { StarterKit } from "@tiptap/starter-kit"

import { Image } from "@tiptap/extension-image"
import { TaskItem } from "@tiptap/extension-task-item"
import { TaskList } from "@tiptap/extension-task-list"
import { TextAlign } from "@tiptap/extension-text-align"
import { Typography } from "@tiptap/extension-typography"
import { Highlight } from "@tiptap/extension-highlight"
import { Subscript } from "@tiptap/extension-subscript"
import { Superscript } from "@tiptap/extension-superscript"
import { Underline } from "@tiptap/extension-underline"

import Placeholder from "@tiptap/extension-placeholder";
import CodeBlock from '@tiptap/extension-code-block';

import Table from '@tiptap/extension-table'
import TableCell from '@tiptap/extension-table-cell'
import TableHeader from '@tiptap/extension-table-header'
import TableRow from '@tiptap/extension-table-row'

import TipTapDraggable from './tiptapdraggable.js'

// https://github.com/johnpuddephatt/gutentap/blob/main/src/components/GutenTap.vue


function getStylesheet(settings) {
  return `
* {
  box-sizing: border-box;
}
.user-select-none {
  -webkit-user-select: none !important;
  -moz-user-select: none!important;
  user-select: none !important;
}

.position-absolute {
  position: absolute !important;
}

.position-relative {
  position: relative !important;
}

.text-editor-toolbar,
.dropdown .dropdown-menu {
  position: absolute;
  background-color: #fff;
  padding: 0.2rem 0.3rem;
  display: none;
  gap: 0.1rem;
  justify-content: center;
  border-radius: 0.65rem;
  border: 1px solid rgba(52,55,60,0.15);
  box-shadow: 0 0.75rem 0.8rem rgba(52,55,60,0.5);
}

.dropdown .dropdown-menu button {
  color: #000;
}

.btn,
.text-editor-toolbar button {
  border: 0;
  border-radius: 0.55rem;
  padding: 0.30rem 0.25rem;
  cursor: pointer;
  transition: background-color 0.2s ease-in-out;
  background-color: transparent;
}

.text-editor-toolbar button svg {
  color: #000
}

.btn:hover,
.text-editor-toolbar button:hover {
  background-color: #eee;
}

.btn:hover svg {
  color: #000;
}

.toolbar-btn-node button.active,
.text-editor-toolbar button.active {
  color: var(--bs-primary);
  background-color:rgba(52,55,60,0.08);
}

.text-editor-toolbar.toolbar-bottom {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1;
  width: 100%;
  border-top: 1px solid rgba(52,55,60,0.15);
}

.text-editor-content {
  border-top: 0;
  // overflow-y: auto;
  padding-top: 1rem;
  width: ${settings.css.textEditorWidth || '100%'};
  ${settings.css.textEditorMargin ? `margin: ${settings.css.textEditorMargin};` : ''}
}

.text-editor-inline {
  color: #222 !important;
  min-height: 320px;
  max-height: initial;
  overflow: hidden;
  background-color: transparent;
  padding: 0.2rem 0.5rem;
  border: 2px solid transparent;
  transition: border 0.2s ease-in-out;
  border-radius: 0.375rem;
}

.text-editor-inline:hover {
  border-color: #dee2e6;
}

.text-editor-inline-active {
  background-color: #fff;
  border-color: #86b7fe !important;
  outline: 0;
  box-shadow: 0 0 0 .25rem rgba(13, 110, 253, .25);
}

.text-editor-content .tiptap {
  padding: 0;
  outline: 0
}

.text-editor-content .tiptap > * {
  margin-top:0;
}

.text-editor-inline .tiptap {
  max-height: ${settings.maxHeight || '180px'};
  overflow-y: auto;
  padding-bottom: 150px;
  outline: 0;
}
  
.dropdown {
  position: relative;
}

.dropdown .dropdown-toggle::after {
  display: inline-block;
  content: "";
  border-top: .23em solid;
  border-right: .23em solid transparent;
  border-bottom: 0;
  border-left: .23em solid transparent;
  height: 7px
}

.dropdown .dropdown-toggle:hover .dropdown-toggle::after {
  border-color: #000
}

.dropdown .dropdown-menu {
  position: absolute;
  z-index: 1000;
  display: none;
  min-width: 8rem;
  padding: 0.2rem;
  margin: 0;
  font-size: var(--bs-dropdown-font-size);
  color: var(--bs-dropdown-color);
  text-align: left;
  list-style: none;
  background-clip: padding-box;
}

.dropdown .dropdown-menu button {
  display: flex;
  align-items: center;
  width: 100%;
  font-size: .95rem
}

.dropdown .dropdown-menu button svg {
  margin-right: 0.2rem;
  color: rgba(0,0,0,0.8);
}

.tiptap ul[data-type=taskList] {
  padding-left: 20px
}

.tiptap ul[data-type=taskList] li {
  align-items: flex-start;
  display: flex;
}

.tiptap ul[data-type=taskList] li>label {
  flex: 0 0 auto;
  margin-right: 0.3rem;
  -webkit-user-select: none;
  -moz-user-select: none;
  user-select: none;
  margin-top: 0.3rem;
}

.tiptap ul[data-type=taskList] li p {
  margin: 0
}

.tiptap p.is-editor-empty:first-child::before {
  color: #adb5bd;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

.tiptap p.is-empty::before {
  color: #adb5bd;
  content: attr(data-placeholder);
  float: left;
  height: 0;
  pointer-events: none;
}

.dropdown-options-list svg {
  width: 1.2rem;
  height: 1.2rem;
}

.dropdown-divider {
  opacity:.1;
  margin: 2px 0;
}

input[type="checkbox"]:checked {
  background-color: #0d6efd;
  border-color: #0d6efd;
}

input[type="checkbox"]:checked {
  background-image: url("data:image/svg+xml,%3csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 20 20'%3e%3cpath fill='none' stroke='%23fff' stroke-linecap='round' stroke-linejoin='round' stroke-width='3' d='m6 10 3 3 6-6'/%3e%3c/svg%3e")
}

input[type="checkbox"] {
  border-radius: .25em;
  flex-shrink: 0;
  width: 1.4em;
  height: 1.4em;
  margin-top: .15em;
  vertical-align: top;
  -webkit-appearance: none;
  -moz-appearance: none;
  appearance: none;
  background-color: var(--bs-form-check-bg);
  background-repeat: no-repeat;
  background-position: 0px center;
  background-size: contain;
  border: var(--bs-border-width) solid var(--bs-border-color);
  -webkit-print-color-adjust: exact;
  color-adjust: exact;
  print-color-adjust: exact;
  border-radius: .35rem;
}

input[type="checkbox"]:focus, input[type="checkbox"]:active {
  border-color: #86b7fe;
  outline: 0;
  box-shadow: 0 0 0 .25rem rgba(13, 110, 253, .25);
}

code {
  display: inline;
  background:rgb(230, 243, 243);
  border: 1px rgb(181, 194, 194) solid;
  border-radius: 9px;
  padding: 0 3px;
}

.d-block {
  display: block !important;
}

.img-fluid {
  max-width: 100%;
  height: auto;
}

.rounded-3 {
  border-radius: 0.75rem !important;
}

`
}

export default class TipTapEditor {
  constructor(settings = {}) {
    this.editorInstance = null;
    this.actions = [
      {
        name: "bold",
        command: 'toggleBold',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-bold"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 5h6a3.5 3.5 0 0 1 0 7h-6z" /><path d="M13 12h1a3.5 3.5 0 0 1 0 7h-7v-7" /></svg>`
      },
      {
        name: "italic",
        command: 'toggleItalic',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-italic"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M11 5l6 0" /><path d="M7 19l6 0" /><path d="M14 5l-4 14" /></svg>`
      },
      {
        name: "strike",
        command: 'toggleStrike',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-strikethrough"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M5 12l14 0" /><path d="M16 6.5a4 2 0 0 0 -4 -1.5h-1a3.5 3.5 0 0 0 0 7h2a3.5 3.5 0 0 1 0 7h-1.5a4 2 0 0 1 -4 -1.5" /></svg>`
      },
      {
        name: 'code',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-code"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 8l-4 4l4 4" /><path d="M17 8l4 4l-4 4" /><path d="M14 4l-4 16" /></svg>`,
        command: 'toggleCode',
      },
      {
        name: "underline",
        command: 'toggleUnderline',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-underline"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 5v5a5 5 0 0 0 10 0v-5" /><path d="M5 19h14" /></svg>`
      },
      {
        name: 'marker',
        icon: `<svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" xmlns="http://www.w3.org/2000/svg"><path fill-rule="evenodd" clip-rule="evenodd" d="M14.7072 4.70711C15.0977 4.31658 15.0977 3.68342 14.7072 3.29289C14.3167 2.90237 13.6835 2.90237 13.293 3.29289L8.69294 7.89286L8.68594 7.9C8.13626 8.46079 7.82837 9.21474 7.82837 10C7.82837 10.2306 7.85491 10.4584 7.90631 10.6795L2.29289 16.2929C2.10536 16.4804 2 16.7348 2 17V20C2 20.5523 2.44772 21 3 21H12C12.2652 21 12.5196 20.8946 12.7071 20.7071L15.3205 18.0937C15.5416 18.1452 15.7695 18.1717 16.0001 18.1717C16.7853 18.1717 17.5393 17.8639 18.1001 17.3142L22.7072 12.7071C23.0977 12.3166 23.0977 11.6834 22.7072 11.2929C22.3167 10.9024 21.6835 10.9024 21.293 11.2929L16.6971 15.8887C16.5105 16.0702 16.2605 16.1717 16.0001 16.1717C15.7397 16.1717 15.4897 16.0702 15.303 15.8887L10.1113 10.697C9.92992 10.5104 9.82837 10.2604 9.82837 10C9.82837 9.73963 9.92992 9.48958 10.1113 9.30297L14.7072 4.70711ZM13.5858 17L9.00004 12.4142L4 17.4142V19H11.5858L13.5858 17Z" fill="currentColor"></path></svg>`,
        command: 'toggleHighlight',
      },
      {
        name: 'dropdown-options-list',
        icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-list"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9 6l11 0" /><path d="M9 12l11 0" /><path d="M9 18l11 0" /><path d="M5 6l0 .01" /><path d="M5 12l0 .01" /><path d="M5 18l0 .01" /></svg>`,
        items: [
          {
            name: "unordered-list",
            command: 'toggleUnorderedList',
            icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-list"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9 6l11 0" /><path d="M9 12l11 0" /><path d="M9 18l11 0" /><path d="M5 6l0 .01" /><path d="M5 12l0 .01" /><path d="M5 18l0 .01" /></svg>`,
            text: 'Unordered',
          },
          {
            name: "ordered-list",
            command: 'toggleOrderedList',
            icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-list-numbers"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M11 6h9" /><path d="M11 12h9" /><path d="M12 18h8" /><path d="M4 16a2 2 0 1 1 4 0c0 .591 -.5 1 -1 1.5l-3 2.5h4" /><path d="M6 10v-6l-2 2" /></svg>`,
            text: 'Ordered',
          },
          {
            name: "tasklist",
            command: 'toggleTaskList',
            icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="24"  height="24"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-list-details"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M13 5h8" /><path d="M13 9h5" /><path d="M13 15h8" /><path d="M13 19h5" /><path d="M3 4m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" /><path d="M3 14m0 1a1 1 0 0 1 1 -1h4a1 1 0 0 1 1 1v4a1 1 0 0 1 -1 1h-4a1 1 0 0 1 -1 -1z" /></svg>`,
            text: 'Task list',
          }
        ]
      }
    ]

    this.editorSettings = settings.editorSettings || {};
    
    this.elements = {
      toolbar: document.createElement('div'),
      // nodeToolbar: document.createElement('div'),
      editorElement: document.createElement('div'),
      innerWrapper: document.createElement('div'),
      inputTitle: settings.inputTitleElement,
      editorInputData: document.createElement('input'),
      wrapper: settings.target
    }

    this.elements.editorInputData.setAttribute('type', 'hidden');
    this.elements.wrapper.appendChild(this.elements.editorInputData);
    // this.elements.innerWrapper.classList.add('position-relative');
    
    this.elements.editorElement.classList.add('text-editor-content');
    this.elements.toolbar.classList.add('text-editor-toolbar')
    this.elements.innerWrapper.classList.add('text-editor-wrapper', 'p-0');
    this.elements.wrapper.insertAdjacentElement('afterbegin', this.elements.innerWrapper);
    
    // set minimum height for the editor
    this.elements.editorElement.style.minHeight = settings.minHeight || '320px';
    this.innerShadow = this.elements.innerWrapper.attachShadow({ mode: "open" });
    
    if(settings.label) {
      let label = document.createElement('label');
      label.classList.add('fw-medium');
      label.innerText = settings.label;
      this.elements.innerWrapper.insertAdjacentElement('beforebegin', label);
    }

    let editorWrapper = document.createElement('div');
      editorWrapper.appendChild(this.elements.toolbar);

    editorWrapper.appendChild(this.elements.editorElement);
    this.innerShadow.appendChild(editorWrapper);

    // apply default styles
    let styles = new CSSStyleSheet();
      styles.replaceSync(getStylesheet(settings));
      this.innerShadow.adoptedStyleSheets = [styles];
    
    this.editorInstance = this.initTipTapEditor(settings)

    // focus the editor when clicking on the editor area
    this.elements.editorElement
        .addEventListener('click', (e) => {
          // console.log(e.target)
          if(e.target == this.elements.editorElement) {
            this.editorInstance.commands.focus('end')
          } else {
            this.editorInstance.chain().focus();
          }
        });
    
    // call the save button callback function
    settings.saveButtonCallback(this.editorInstance,
            this.elements.toolbar, this.elements.inputTitle);

    // check if there are any extra HTML attributes to set on the editor element
    if(settings.attributes && typeof settings.attributes === 'object') {
      Object.keys(settings.attributes).forEach(attr => {
        if (attr === 'class' && Array.isArray(settings.attributes[attr])) {
          this.elements.editorElement.classList.add(...settings.attributes[attr]);
        } else if (attr === 'class' && typeof settings.attributes[attr] === 'string') {
          this.elements.editorElement.classList.add(settings.attributes[attr]);
        } else if (attr === 'style' && typeof settings.attributes[attr] === 'object') {
          Object.keys(settings.attributes[attr]).forEach(style => {
            this.elements.editorElement.style[style] = settings.attributes[attr][style];
          });
        } else if (attr === 'data' && typeof settings.attributes[attr] === 'object') {
          Object.keys(settings.attributes[attr]).forEach(dataAttr => {
            this.elements.editorElement.setAttribute(`data-${dataAttr}`, settings.attributes[attr][dataAttr]);
          });
        } else {
          this.elements.editorElement.setAttribute(attr, settings.attributes[attr]);
        }
      });
    }

    if(settings.editorOptions) {
      this.editorInstance.setOptions(settings.editorOptions);
    }

    for(let action of this.actions) {
      let button = document.createElement('button');
      if(!action.items) {
        // if action button has a name, set it as the class name
        button.className = `${action.name} user-select-none`;
        button.innerHTML = action.icon != null ? action.icon : action.name;
        button.addEventListener('click', (e) => {
          e.preventDefault();
          this.editorInstance.chain().focus()[action.command]().run();
        });
      } else {
        // otherwise, the button may contain a dropdown of items
        // so we'll create a bootstrap dropdown button with items
        button = document.createElement('div');
        button.className = `dropdown ${action.name} user-select-none`;
        button.setAttribute('role', 'group');
        button.setAttribute('aria-label', action.name);
        button.innerHTML = `<button type="button" class="btn btn-secondary dropdown-toggle" data-bs-toggle="dropdown" aria-expanded="false">${action.icon != null ? action.icon : action.name}</button>`;
        let dropdownMenu = document.createElement('ul');
        dropdownMenu.className = 'dropdown-menu';
        button.appendChild(dropdownMenu);
        button.addEventListener('click', (e) => {
          e.preventDefault();
          e.stopPropagation();
          // toggle the dropdown menu visibility
          dropdownMenu.classList.toggle('d-block');
        });
        for(let item of action.items) {
          let itemButton = document.createElement('button');
          itemButton.className = `${item.name}`;
          itemButton.innerHTML = item.icon != null ? item.icon + ' ' + item.text : item.name;
          itemButton.addEventListener('click', (e) => {
            e.preventDefault();
            this.editorInstance.chain().focus()[item.command]().run();
          });
          dropdownMenu.appendChild(itemButton);
        }
      }
      this.elements.toolbar.insertAdjacentElement('beforeend', button);
    }

    // check the network state, using addEventListener
    // if the network is offline, we'll keep the editor
    // in active state and save the content to IndexedDB
    window.addEventListener('offline', () => {
      console.log('Network is offline, saving editor content to IndexedDB');
    });

    window.addEventListener('online', () => {
      console.log('Network is online, syncing editor content with server');
      // here you can implement the logic to sync the content with the server
    });
  }

  initTipTapEditor(settings) {
    const filterEditorActions = (editor, availableActions, selection) => {
      for(let action of this.actions) {
        if(availableActions.length > 0 && !availableActions.includes(action.name)) {
          let button = this
                  .innerShadow
                  .querySelector(`.text-editor-toolbar .${action.name}`);
          if(button.tagName === 'DIV') {
            button = button.querySelector('button'); // get the button inside the dropdown
          }
          button.style.display = 'none';
          continue;
        } else {
          if(selection.rangeCount > 0 && !selection.getRangeAt(0).collapsed) {
            if(action.name == 'image') {
              let button = this.innerShadow.querySelector(`.text-editor-toolbar .${action.name}`);
              button.style.display = 'none';
            }
          }
        }
        
        // show the action button
        let pressed = editor.isActive(action.name);
        let button = this.innerShadow.querySelector(`.text-editor-toolbar .${action.name}`);
        
        if(button.tagName === 'DIV') {
          button = button.querySelector('button');   // get the button inside the dropdown
        }
        
        button.classList.add('border-0')
        button.setAttribute('tabindex', '-1');      // set tabindex to -1 to prevent focus
        
        if(button) {
          if(pressed) {
            button.classList.add('active');
          } else {
            button.classList.remove('active');
          }
          button.setAttribute('aria-pressed', pressed); // set aria-pressed attribute
        }
      }
    }

    return new Editor({
      element: this.elements.editorElement,
      extensions: [
        TextAlign.configure({ types: ["heading", "paragraph"] }),
        Underline,
        TaskList,
        TaskItem.configure({
          nested: true,
          onReadOnlyChecked: (node, checked) => {
            // console.log(node)
          }
        }),
        Highlight.configure({
          multicolor: true
        }),
        Image.configure({
          HTMLAttributes: {
            class: 'img-fluid rounded-3',
          },
        }),
        Typography,
        Superscript,
        Subscript,
        StarterKit,
        CodeBlock.configure({
          HTMLAttributes: {
            style: `
              background-color: #eee;
              border-radius: 0.375rem;
              padding: 0.5rem;
              font-family: monospace;
            `,
          }
        }),
        Placeholder.configure({
          placeholder: `Type / to choose a block`,
        }),
        Table.configure({
          resizable: true,
        }),
        TableRow,
        TableHeader,
        TableCell,
        TipTapDraggable.configure({
          innerShadow: this.innerShadow,
          onHover: (node, editor) => {
            // console.log('Node changed:', node);
            // console.log('Editor:', editor);
          }
        }),
      ],
      editorProps: {
        transformPastedText: (text) => {
          // transform pasted text to plain text
          return html.replace(/<(?!br\s*\/?)[^>]+>/g, ''); // remove HTML tags except for <br>
        },
        transformPastedHTML: (html) => {
          // transform pasted HTML to plain text
          return html.replace(/<(?!br\s*\/?)[^>]+>/g, ''); // remove HTML tags except for <br>
        }
      },
      onCreate: ({ editor }) => {
        this.elements.editorInputData.setAttribute('value',
          JSON.stringify(this.editorInstance.getJSON()));
      },
      onUpdate: ({ editor }) => {
        // serialize the editor content to JSON
        // and set it to the hidden input
        this.elements.editorInputData.setAttribute('value',
          JSON.stringify(this.editorInstance.getJSON()));
      },
      onSelectionUpdate: ({ editor }) => {

      },
      onBlur: ({ editor, event }) => {
        // Hide the toolbar when editor loses focus

        const toolbar = this.elements.toolbar;
        const nextFocused = event.relatedTarget;

        if (toolbar.contains(nextFocused)) {
          // Focus is moving to the toolbar, don't hide it
          return;
        }

        this.elements.toolbar.style.display = 'none';

        // Optionally, move toolbar to the click position outside editor
        if (event && event.clientX && event.clientY) {
          this.elements.toolbar.style.top = `${event.clientY}px`;
          this.elements.toolbar.style.left = `${event.clientX}px`;
        }
      },
      onFocus: ({ editor, event }) => {
        // Show the toolbar when editor gains focus
        console.log('Editor focused');
      },
      onTransaction: ({ editor, transaction }) => {
        // This event is triggered on any transaction, including selection
        // changes, content updates, etc.
        if(!editor.isEditable) return;

        let pos = posToDOMRect(editor.view,
                    editor.state.selection.ranges[0].$from.pos,
                    this.editorInstance.state.selection.ranges[0].$to.pos)
        const { from } = transaction.selection
        const resolvedPos = transaction.doc.resolve(from)
        const node = resolvedPos.nodeAfter || resolvedPos.parent
        
        let posFrom = editor.state.selection.ranges[0].$from.pos;
        let posTo = editor.state.selection.ranges[0].$to.pos;

        // Checking if a selection is made
        // This is also available on clicking any content node
        if(transaction.selectionSet) {
          var availableActions = []
          // console.log(editor.isActive('image'))
          if (editor.isActive('image')) {
            console.log('Image clicked');
            availableActions = ['bold'];
          } else if (editor.isActive('paragraph')) {
            console.log('Paragraph clicked');
          } else {
            // ...reset toolbar...
          }
          
          const selection = this.innerShadow.getSelection();
          filterEditorActions(editor, availableActions, selection)
          
          if(posFrom !== posTo) {
            if (selection.rangeCount > 0) {
                const range = selection.getRangeAt(0);
                const rect = range.getBoundingClientRect();
                const containerRect = this.elements.innerWrapper.getBoundingClientRect();
              this.elements.toolbar.style.top = `${rect.top - containerRect.top + 50}px`;
              this.elements.toolbar.style.left = `${rect.left - containerRect.left}px`;
              this.elements.toolbar.style.display = 'flex';
            }
          } else {
            // if no selection, hide the toolbar
            this.elements.toolbar.style.display = 'none';

            let dropDownElements = this.innerShadow.querySelectorAll('.dropdown .dropdown-menu');
            dropDownElements.forEach(dropdown => {
              dropdown.classList.remove('d-block');
            });
            for(let action of this.actions) {
              let button = this.innerShadow.querySelector(`.text-editor-toolbar .${action.name}`);
              if(button.tagName === 'DIV') {
                // get the button inside the dropdown
                button = button.querySelector('button');
              }
              // reset all buttons to visible, in case they were hidden
              button.style.display = 'block';
            }
          }
        }
      },
      onFocus: ({ editor }) => {
        // console.log(editor)
      },
      content: settings.data || null,
    })
  }
}