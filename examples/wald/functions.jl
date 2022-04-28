function sample_mixture(ν, α, θ)
    if rand() ≤ .8
        dist = Wald(;ν, α, θ)
        rt = min(rand(dist), 20.0)
    end
    return rand(Uniform(.05, 2))
end

function rand_parms()
    ν = rand(Uniform(0, 2))
    α = rand(Uniform(.5, 2))
    θ = rand(Uniform(.05, .250))
    return (;ν, α, θ)
end

function make_training_data(n)
    output = fill(0.0, 4, n)    
    ν, α, θ = rand_parms()
    x = map(_ -> sample_mixture(ν, α, θ), 1:n)
    for (i,v) in enumerate(x)
        output[:,i] = [ν, α, θ, v]
    end
    return output
end

function train_model(model, n_epochs, loss_fn, all_data, opt; show_progress=true)
    meter = Progress(n_epochs; enabled=show_progress)
    losses = zeros(n_epochs)
    max_loss = -Inf
    min_loss = Inf
    @showprogress for i in 1:n_epochs
        Flux.train!(loss_fn, params(model), all_data, opt)
        losses[i] = loss_fn(data, labels)
        loss = round(losses[i], digits=4)
        max_loss = loss >  max_loss ? loss : max_loss 
        min_loss = loss <  min_loss ? loss : min_loss
        values = [(:iter,i),(:loss,loss), (:max_loss, max_loss), (:min_loss,min_loss)]
        next!(meter; showvalues = values)
    end
    return loss
end

function gen_label(data)
    pdf(Wald(;ν=data[1],α=data[2], θ=data[3]), data[4])
end