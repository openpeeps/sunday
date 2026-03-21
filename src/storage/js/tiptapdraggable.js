import { Extension, posToDOMRect } from '@tiptap/core';
import {NodeSelection, Plugin, PluginKey, TextSelection} from '@tiptap/pm/state';

function nodeDOMAtCoords(coords, options) {
  const selectors = [
    'li',
    'p:not(:first-child)',
    'pre',
    'blockquote',
    'h1',
    'h2',
    'h3',
    'h4',
    'h5',
    'h6',
    // ...options.customNodes.map((node) => `[data-type=${node}]`),
  ].join(', ');
  return document
    .elementsFromPoint(coords.x, coords.y)
    .find(
      (elem) =>
        elem.parentElement?.matches?.('.ProseMirror') ||
        elem.matches(selectors)
    );
}

/**
 * Create a draggable plugin for TipTap editor
 * @param {Object} options 
 */
function DraggablePlugin(options) {
  
  let dragElement = document.createElement('div');
      dragElement.classList.add('dropdown');
      dragElement.classList.add('toolbar-btn-node', 'position-absolute');
      dragElement.style.display = 'none';
  let toolbarMenu = document.createElement('ul');
      toolbarMenu.classList.add('dropdown-menu');
      toolbarMenu.style.position = 'absolute';
  let toggle = document.createElement('button');
      toggle.classList.add('dropdown-toggle');
      toggle.setAttribute('data-bs-toggle', 'dropdown-toggle');
      toggle.innerHTML = `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-grip-vertical"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M9 5m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M9 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M9 19m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M15 5m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M15 12m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /><path d="M15 19m-1 0a1 1 0 1 0 2 0a1 1 0 1 0 -2 0" /></svg>`;
      toggle.style.border = 0;
      toggle.style.background = 'transparent';
      toggle.style.cursor = 'pointer';

  dragElement.appendChild(toggle);
  dragElement.appendChild(toolbarMenu);

  function getActiveNodeElement(view, event) {
    let pos = view.posAtDOM(event.target, 0);
    if (typeof pos !== 'number' || pos <= 0) {
      return null;
    }
    try {
      let textNode = view.state.doc.nodeAt(pos);
      let resolvedPos = view.state.doc.resolve(pos);
      return {
        textNode: textNode,
        node: resolvedPos.parent,
        element: view.nodeDOM(resolvedPos.before(resolvedPos.depth)),
      };
    } catch (error) {
      // console.log('Error getting active node element:', error);
      return null;
    }
  }

  // Store the currently active element
  let activeElementNode = null;

  return new Plugin({
    key: new PluginKey(options.pluginKey),
    view: (view) => {
      view?.dom?.parentElement.appendChild(dragElement);
      toggle.addEventListener('click', (e) => {
        // clicking the drag handle should not trigger
        // the editor click event instead will open the node menu
        e.stopPropagation();
        e.preventDefault();
        // create a bootstrap dropdown menu
        const node = view.state.selection.$from.node();
        const nodeElement = view.nodeDOM(view.state.selection.$from.pos);
        let toolbarActions = [
          {
            icon: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" class="icon icon-tabler icons-tabler-outline icon-tabler-photo-plus"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M15 8h.01" /><path d="M12.5 21h-6.5a3 3 0 0 1 -3 -3v-12a3 3 0 0 1 3 -3h12a3 3 0 0 1 3 3v6.5" /><path d="M3 16l5 -5c.928 -.893 2.072 -.893 3 0l4 4" /><path d="M14 14l1 -1c.67 -.644 1.45 -.824 2.182 -.54" /><path d="M16 19h6" /><path d="M19 16v6" /></svg>`,
            label: 'Add Image',
            action: 'insertImage',
            // command: 'setImage',
          },
          {
            type: 'divider'
          },
          {
            icon: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="currentColor" class="icon icon-tabler icons-tabler-filled icon-tabler-arrow-badge-up"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M11.375 6.22l-5 4a1 1 0 0 0 -.375 .78v6l.006 .112a1 1 0 0 0 1.619 .669l4.375 -3.501l4.375 3.5a1 1 0 0 0 1.625 -.78v-6a1 1 0 0 0 -.375 -.78l-5 -4a1 1 0 0 0 -1.25 0z" /></svg>`,
            action: 'moveUp', 
            label: 'Up',
            commandKey: 'moveNodeUp',
          },
          {
            icon: `<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="currentColor" class="icon icon-tabler icons-tabler-filled icon-tabler-arrow-badge-down"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M16.375 6.22l-4.375 3.498l-4.375 -3.5a1 1 0 0 0 -1.625 .782v6a1 1 0 0 0 .375 .78l5 4a1 1 0 0 0 1.25 0l5 -4a1 1 0 0 0 .375 -.78v-6a1 1 0 0 0 -1.625 -.78z" /></svg>`,
            action: 'moveDown', 
            label: 'Down',
            commandKey: 'moveNodeDown',
          },
          {
            type: 'divider'
          },
          {
            icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="none"  stroke="currentColor"  stroke-width="2"  stroke-linecap="round"  stroke-linejoin="round"  class="icon icon-tabler icons-tabler-outline icon-tabler-copy"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M7 7m0 2.667a2.667 2.667 0 0 1 2.667 -2.667h8.666a2.667 2.667 0 0 1 2.667 2.667v8.666a2.667 2.667 0 0 1 -2.667 2.667h-8.666a2.667 2.667 0 0 1 -2.667 -2.667z" /><path d="M4.012 16.737a2.005 2.005 0 0 1 -1.012 -1.737v-10c0 -1.1 .9 -2 2 -2h10c.75 0 1.158 .385 1.5 1" /></svg>`,
            action: 'duplicate', 
            label: 'Duplicate',
            commandKey: 'duplicateNode',
          },
          {
            icon: `<svg  xmlns="http://www.w3.org/2000/svg"  width="18"  height="18"  viewBox="0 0 24 24"  fill="currentColor"  class="icon icon-tabler icons-tabler-filled icon-tabler-trash-x"><path stroke="none" d="M0 0h24v24H0z" fill="none"/><path d="M20 6a1 1 0 0 1 .117 1.993l-.117 .007h-.081l-.919 11a3 3 0 0 1 -2.824 2.995l-.176 .005h-8c-1.598 0 -2.904 -1.249 -2.992 -2.75l-.005 -.167l-.923 -11.083h-.08a1 1 0 0 1 -.117 -1.993l.117 -.007h16zm-9.489 5.14a1 1 0 0 0 -1.218 1.567l1.292 1.293l-1.292 1.293l-.083 .094a1 1 0 0 0 1.497 1.32l1.293 -1.292l1.293 1.292l.094 .083a1 1 0 0 0 1.32 -1.497l-1.292 -1.293l1.292 -1.293l.083 -.094a1 1 0 0 0 -1.497 -1.32l-1.293 1.292l-1.293 -1.292l-.094 -.083z" /><path d="M14 2a2 2 0 0 1 2 2a1 1 0 0 1 -1.993 .117l-.007 -.117h-4l-.007 .117a1 1 0 0 1 -1.993 -.117a2 2 0 0 1 1.85 -1.995l.15 -.005h4z" /></svg>`,
            action: 'delete', 
            label: 'Delete',
            commandKey: 'deleteNode',
          }
        ];
        
        while (toolbarMenu.firstChild) {
          // delete the previous menu items from children array
          toolbarMenu.removeChild(toolbarMenu.firstChild);
        }

        for (let action of toolbarActions) {
          let button = document.createElement('button');
          if (action.type && action.type === 'divider') {
            let divider = document.createElement('hr');
            divider.classList.add('dropdown-divider');
            toolbarMenu.appendChild(divider);
            continue;
          }
          button.classList.add('dropdown-item', 'btn');
          button.setAttribute('data-action', action.action);
          if (action.icon) {button.innerHTML = action.icon};
          button.insertAdjacentHTML('beforeend', `<span>${action.label}</span>`);
          button.addEventListener('click', (e) => {
            e.stopPropagation();
            e.preventDefault();
            if (action.commandKey) {
              // Execute the command using the editor's command system
              options.editor.commands[action.commandKey](activeElementNode, {toolbarMenu, dragElement})
            }
          });
          toolbarMenu.appendChild(button);
        }
        toolbarMenu.classList.toggle('d-block')
      });

      dragElement.addEventListener('mouseover', (e) => {
        clearTimeout(dragElement.hideTimeout);
        dragElement.style.display = 'block';
      });
      
      return {
        destroy: () => {
          console.log('Destroying drag handle plugin');
          if (dragElement) {
            dragElement.remove();
            dragElement = null;
          }
        }
      }
    },
    props: {
      handleDOMEvents: {
        /**
         * Click event to prevent the editor from
         * losing focus when clicking on the drag handle.
        */
        click: (view, event) => {
          // console.log('Editor was clicked!', event);
          return false;
        },
        /**
         * Mouseover event to show the drag handle
         * and position it relative to the hovered node.
        */
        mouseover: (view, event) => {
          clearTimeout(dragElement.hideTimeout);
          if(dragElement.hasAttribute('data-hover-active')) {
            return
          }
          let active = getActiveNodeElement(view, event)
          if(active) {
            activeElementNode = active.element
            dragElement.style.display = 'block';
            dragElement.style.left = `${active.element.offsetLeft - 40}px`;
            dragElement.style.top = `${active.element.offsetTop + 5}px`;
            options.onHover ? options.onHover(active.element, view) : null;
          }
          return false;
        },
        /**
         * Mouseout event to hide the drag handle
        */
        mouseout: (view, event) => {
          if(!dragElement.hasAttribute('data-hover-active')) {
            dragElement.hideTimeout = setTimeout(() => {
              dragElement.style.display = 'none';
            }, 450)
          }
          return false;
        },
        dblclick: (view, e) => {
          let active = getActiveNodeElement(view, e)
          // todo
        },
        /**
         * Keydown event to activate the drag handle
         * when the slash key is pressed.
        */
        keydown: (view, event) => {
          if (event.code === 'Slash') {
            dragElement.setAttribute('data-hover-active', 'true');
            toolbarMenu.style.display = 'block';
            dragElement.style.display = 'block';
          }
        }
      },
    },
  })
}

const TipTapDraggable = Extension.create({
  name: 'tipTapDraggable',
  addOptions() {
    return {
      innerShadow: null,
      dragHandleWidth: 20,
      scrollTreshold: 100,
      excludedTags: [],
      customNodes: [],
      onHover: () => null
    };
  },
  addCommands() {
    function focusNode(editor, moveUp = false) {
      let nextPos = moveUp ? editor.state.selection.$from.pos - 1 : editor.state.selection.$from.pos + 1;
      let pos = editor.state.doc.resolve(nextPos);
      editor.view.dispatch(editor.state.tr.setSelection(new NodeSelection(pos)));
      editor.view.focus();
    }

    return {
      lockDragHandle: () => ({ editor }) => {
        this.options.locked = true
        return editor.commands.setMeta('lockDragHandle', this.options.locked)
      },
      unlockDragHandle: () => ({ editor }) => {
        this.options.locked = false
        return editor.commands.setMeta('lockDragHandle', this.options.locked)
      },
      toggleDragHandle: () => ({ editor }) => {
        this.options.locked = !this.options.locked
        return editor.commands.setMeta('lockDragHandle', this.options.locked)
      },
      duplicateNode: (node) => ({ editor }) => {
        node.insertAdjacentElement('afterend', node.cloneNode(true));
      },

      moveNodeUp: (node) => ({ editor }) => {
        if (node && node.previousElementSibling) {
          node.previousElementSibling.insertAdjacentElement('beforebegin', node);
          focusNode(editor, true);
        }
      },
      moveNodeDown: (node) => ({ editor }) => {
        if (node && node.nextElementSibling) {
          node.nextElementSibling.insertAdjacentElement('afterend', node);
          focusNode(editor, false);
        }
      },

      deleteNode: (node, {dragElement}) => ({ editor }) => {
        if (node) {
          dragElement.style.display = 'none';
          if(node.previousElementSibling) {
            // focus to the previous node
            let pos = editor.state.doc.resolve(editor.state.selection.$from.pos - 1);
            editor.view.dispatch(editor.state.tr.setSelection(new NodeSelection(pos)));
            editor.view.focus();
          } else if(node.nextElementSibling) {
            // focus to the next node
            let pos = editor.state.doc.resolve(editor.state.selection.$from.pos + 1);
            editor.view.dispatch(editor.state.tr.setSelection(new NodeSelection(pos)));
            editor.view.focus();
          } else {
            // focus to the parent node
            let pos = editor.state.doc.resolve(editor.state.selection.$from.before());
            editor.view.dispatch(editor.state.tr.setSelection(new NodeSelection(pos)));
            editor.view.focus();
          }
          node.remove();
        }
      }
    }
  },
  addProseMirrorPlugins() {
    let styles = new CSSStyleSheet();
      styles.replaceSync(`
        *[data-node-active="true"] {
          outline: 2px solid #fff;
          outline-offset: -2px;
        }
    `);
    this.options.innerShadow.adoptedStyleSheets.push(styles);
    return [
      DraggablePlugin({
        pluginKey: 'tipTapDraggable',
        dragHandleWidth: this.options.dragHandleWidth,
        scrollTreshold: this.options.scrollTreshold,
        dragHandleSelector: this.options.dragHandleSelector,
        excludedTags: this.options.excludedTags,
        customNodes: this.options.customNodes,
        onHover: this.options.onHover,
        innerShadow: this.options.innerShadow,
        editor: this.editor,
      }),
    ];
  },
});

export default TipTapDraggable;