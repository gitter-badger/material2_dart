import 'dart:async';
import "package:angular2/core.dart";
import "portal.dart";

/**
 * Directive version of a `TemplatePortal`. Because the directive *is* a TemplatePortal,
 * the directive instance itself can be attached to a host, enabling declarative use of portals.
 *
 * Usage:
 * <template portal #greeting>
 *   <p> Hello {{name}} </p>
 * </template>
 */
@Directive(selector: "[portal]", exportAs: "portal")
class TemplatePortalDirective extends TemplatePortal {
  TemplatePortalDirective(
      TemplateRef templateRef, ViewContainerRef viewContainerRef)
      : super(templateRef, viewContainerRef);
}

/**
 * Directive version of a PortalHost. Because the directive *is* a PortalHost, portals can be
 * directly attached to it, enabling declarative use.
 *
 * Usage:
 * <template [portalHost]="greeting"></template>
 */
@Directive(selector: "[portalHost]", inputs: const ["portal: portalHost"])
class PortalHostDirective extends BasePortalHost {
  ComponentResolver _componentResolver;
  ViewContainerRef _viewContainerRef;

  /** The attached portal. */
  Portal<dynamic> _portal;

  PortalHostDirective(this._componentResolver, this._viewContainerRef);

  Portal<dynamic> get portal => _portal;

  set portal(Portal<dynamic> p) {
    _replaceAttachedPortal(p);
  }

  /** Attach the given ComponentPortal to this PortlHost using the ComponentResolver. */
  Future<ComponentRef> attachComponentPortal(ComponentPortal portal) async {
    portal.setAttachedHost(this);
    // If the portal specifies an origin, use that as the logical location of the component

    // in the application tree. Otherwise use the location of this PortalHost.
    var viewContainerRef = portal.viewContainerRef != null
        ? portal.viewContainerRef
        : _viewContainerRef;
    var componentFactory =
        await _componentResolver.resolveComponent(portal.component);
    var ref = viewContainerRef.createComponent(componentFactory,
        viewContainerRef.length, viewContainerRef.parentInjector);
    setDisposeFn(() => ref.destroy());
    return ref;
  }

  /** Attach the given TemplatePortal to this PortlHost as an embedded View. */
  Future<Map<String, dynamic>> attachTemplatePortal(TemplatePortal portal) {
    portal.setAttachedHost(this);
    _viewContainerRef.createEmbeddedView(portal.templateRef);
    setDisposeFn(() => _viewContainerRef.clear());
    // TODO(jelbourn): return locals from view
    return new Future.value(new Map<String, dynamic>());
  }

  /** Detatches the currently attached Portal (if there is one) and attaches the given Portal. */
  void _replaceAttachedPortal(Portal<dynamic> p) {
    var maybeDetach = hasAttached() ? detach() : new Future.value();
    maybeDetach.then((_) {
      if (p != null) {
        attach(p);
        _portal = p;
      }
    });
  }
}

const List PORTAL_DIRECTIVES = const [
  TemplatePortalDirective,
  PortalHostDirective
];
