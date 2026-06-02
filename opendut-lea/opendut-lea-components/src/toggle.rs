use leptos::prelude::*;

#[derive(Clone, Copy, Debug, Default, PartialEq)]
pub enum ToggleState {
    #[default]
    Enabled,
    Disabled,
    Loading,
}

#[component]
pub fn Toggle<F>(
    #[prop(optional, into)] text: Option<Signal<String>>,
    is_active: Signal<bool>,
    on_action: F,
    #[prop(optional, into)] state: Option<Signal<ToggleState>>,
) -> impl IntoView
where
    F: Fn() + 'static,
{
    let state = state.unwrap_or(Signal::from(ToggleState::Enabled));

    view! {
        <div
            class="is-flex is-align-items-center is-justify-content-center"
            on:click=move |event| event.stop_propagation()
        >
            <label class="dut-toggle"
                class=("active", move || is_active.get())
                class=("disabled", move || state.get() == ToggleState::Disabled)
                class=("loading", move || state.get() == ToggleState::Loading)
                on:click=move |_| {
                    if state.get() == ToggleState::Enabled {
                        on_action()
                    }
                }
            />
            {
                text.map(|text| {
                    view! {
                        <span class="pl-2">{ text }</span>
                    }
                })
            }
        </div>
    }
}
