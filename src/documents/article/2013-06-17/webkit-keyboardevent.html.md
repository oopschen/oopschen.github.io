---
layout: post
title: webkit下的KeyboardEvent模拟
tags: webkit,js模拟KeyboardEvent
date: 2013-06-17 10:14:13
udate: 2013-06-17 10:14:13
category: 
---
[dom2]: http://www.w3.org/TR/DOM-Level-2-Events/ "DOM2 EVENT SPEC"
[dom3]: http://www.w3.org/TR/DOM-Level-3-Events/ "DOM3 EVENT SPEC"

在javascript中模拟dom的事件是一件非常有趣的事情,他不仅可以将人工机器化,也让页面变得更加丰富。DOM时间参考资料可参见[DOM2][dom2]和[DOM3][dom3]。   
  
#### 常用方式
我们在javascript中模拟dom事件一般用两种方法：  

##### 调用事件函数

    element.click();

##### 创建事件对象

    var evt = document.createEvent("MouseEvent");
    evt.initMouseEvent(
      "click", true, true, document.defaultView,
      1, window.screenX, window.screenY,
      clientX, clientY,
      0, null
    );
    element.dispatchEvent(evt);

##### 区别
这两种方式其实没有区别,都会进行完整的时间传递从capture phase到target phase,最后bubble phase。唯一的区别是后者可以自定义一些事件相关的参数,比如点击的位置等。  
  
#### webkit 中KeyboardEvent
在webkit中无法通过KeyboardEvent来完全模拟按键,原因是webkit中的实现和DOM3的标准不一致。我们来看下DOM3中对KeyboardEvent的initKeyboardEvent函数的定义：  

    // Event Constructor Syntax:
    [Constructor(DOMString typeArg, optional KeyboardEventInit keyboardEventInitDict)]
    partial interface KeyboardEvent
    {
      // Originally introduced (and deprecated) in DOM Level 3:
      void initKeyboardEvent(DOMString typeArg,
                             boolean canBubbleArg,
                             boolean cancelableArg,
                             AbstractView? viewArg,
                             DOMString charArg,
                             DOMString keyArg,
                             unsigned long locationArg,
                             DOMString modifiersListArg,
                             boolean repeat,
                             DOMString localeArg);
    };
  
我们来主要看几个参数：  
1. charArg表示按键的值和keyArg等同,如果值是不可见字符则charArg为空字符
2. modifiersListArg表示是否有按键Control等修饰符
  
然而在webkit中*core/dom/KeyboardEvent.idl*中确是这样的代码:

    // FIXME: this does not match the version in the DOM spec.
    void initKeyboardEvent([Default=Undefined] optional DOMString type, 
                           [Default=Undefined] optional boolean canBubble, 
                           [Default=Undefined] optional boolean cancelable, 
                           [Default=Undefined] optional DOMWindow view, 
                           [Default=Undefined] optional DOMString keyIdentifier,
                           [Default=Undefined] optional unsigned long keyLocation,
                           [Default=Undefined] optional boolean ctrlKey,
                           [Default=Undefined] optional boolean altKey,
                           [Default=Undefined] optional boolean shiftKey,
                           [Default=Undefined] optional boolean metaKey,
                           [Default=Undefined] optional boolean altGraphKey);
  
和上面完全不一致,而从实现的类的177到200行来看我们无法通过创建KeyboardEvent来创建一个按键,因为无法设置keyCode值。

    int KeyboardEvent::keyCode() const
    {
        // IE: virtual key code for keyup/keydown, character code for keypress
        // Firefox: virtual key code for keyup/keydown, zero for keypress
        // We match IE.
        if (!m_keyEvent)
            return 0;
        if (type() == eventNames().keydownEvent || type() == eventNames().keyupEvent)
            return windowsVirtualKeyCodeWithoutLocation(m_keyEvent->windowsVirtualKeyCode());

        return charCode();
    }
    int KeyboardEvent::charCode() const
    {
        // IE: not supported
        // Firefox: 0 for keydown/keyup events, character code for keypress
        // We match Firefox

        if (!m_keyEvent || (type() != eventNames().keypressEvent))
            return 0;
        String text = m_keyEvent->text();
        return static_cast<int>(text.characterStartingAt(0));
    }

m_keyEvent是一个PlatformKeyboardEvent的实例,而这个实例无法通过js创建。  
  
#### 总结
在这个实现未被修改之前,我们仍无法通过javascript在webkit内核下创建一个真实的按键效果。
