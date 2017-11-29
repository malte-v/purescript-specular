// data Node :: Type

// createTextNodeImpl :: String -> IOSync Node
exports.createTextNodeImpl = function(text) {
  return function() {
    return document.createTextNode(text);
  };
};

// createDocumentFragmentImpl :: IOSync Node
exports.createDocumentFragmentImpl = function() {
  return document.createDocumentFragment();
};

// createElementImpl :: TagName -> IOSync Node
exports.createElementImpl = function(tag) {
  return function() {
    return document.createElement(tag);
  };
};

// setAttributeImpl :: Node -> String -> String -> IOSync Unit
exports.setAttributeImpl = function(node) {
  return function(name) {
    return function(value) {
      return function() {
        node.setAttribute(name, value);
      };
    };
  };
};

// removeAttributesImpl :: Node -> Array String -> IOSync Unit
exports.removeAttributesImpl = function(node) {
  return function(names) {
    return function() {
      names.forEach(function(name) {
        node.removeAttribute(name);
      });
    };
  };
};

// parentNodeImpl :: (Node -> Maybe Node) -> Maybe Node -> Node -> IOSync (Maybe Node)
exports.parentNodeImpl = function(Just) {
  return function(Nothing) {
    return function(node) {
      return function() {
        var parent = node.parentNode;
        if(parent !== null) {
          return Just(parent);
        } else {
          return Nothing;
        }
      };
    };
  };
};

// insertBeforeImpl :: Node -> Node -> Node -> IOSync Unit
exports.insertBeforeImpl = function(newNode) {
  return function(nodeAfter) {
    return function(parent) {
      return function() {
        parent.insertBefore(newNode, nodeAfter);
      };
    };
  };
};

// appendChildImpl :: Node -> Node -> IOSync Unit
exports.appendChildImpl = function(newNode) {
  return function(parent) {
    return function() {
      parent.appendChild(newNode);
    };
  };
};

// removeAllBetweenImpl :: Node -> Node -> IOSync Unit
exports.removeAllBetweenImpl = function(from) {
  return function(to) {
    return function() {
      var node = from;
      while(node !== to) {
        var next = node.nextSibling;
        node.parentNode.removeChild(node);
        node = next;
      }
    };
  };
};

// outerHTML :: Node -> IOSync String
exports.outerHTML = function(node) {
  return function() {
    return node.outerHTML;
  };
};